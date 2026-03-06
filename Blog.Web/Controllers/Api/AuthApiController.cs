using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Blog.Core.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Blog.Web.Controllers.Api;

[ApiController]
[Route("api/v1")]
[Produces("application/json")]
public class AuthApiController : ControllerBase
{
    private readonly AuthService _auth;
    private readonly IUserRepository _users;
    private readonly IConfiguration _config;

    public AuthApiController(AuthService auth, IUserRepository users, IConfiguration config)
    {
        _auth = auth;
        _users = users;
        _config = config;
    }

    [HttpPost("auth/login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest req)
    {
        var (user, error) = await _auth.ValidateLoginAsync(req.Email, req.Password);
        if (user == null)
            return Unauthorized(ApiError(401, error ?? "Invalid credentials."));

        var accessToken = GenerateAccessToken(user);

        return Ok(ApiOk(new { accessToken, expiresIn = 900, tokenType = "Bearer" }));
    }

    [HttpPost("auth/logout")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public IActionResult Logout()
    {
        return Ok(ApiOk("Logged out."));
    }

    private string GenerateAccessToken(User user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expiry = int.Parse(_config["Jwt:AccessTokenExpiryMinutes"] ?? "15");

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Name, user.DisplayName),
            new Claim(ClaimTypes.Role, user.Role),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiry),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static object ApiOk(object data) => new { data };
    private static object ApiError(int code, string error) =>
        new { statusCode = code, error, traceId = System.Diagnostics.Activity.Current?.Id };
}

public record LoginRequest(string Email, string Password);
