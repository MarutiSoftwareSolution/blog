using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Blog.Web.Controllers.Api;

[ApiController]
[Route("api/v1")]
[Produces("application/json")]
public class MiscApiController : ControllerBase
{
    private readonly ICategoryRepository _categories;
    private readonly ITagRepository _tags;
    private readonly ICommentRepository _comments;
    private readonly IMediaRepository _media;
    private readonly IUserRepository _users;
    private readonly ITenantContext _tenantContext;

    public MiscApiController(ICategoryRepository categories, ITagRepository tags,
        ICommentRepository comments, IMediaRepository media, IUserRepository users,
        ITenantContext tenantContext)
    {
        _categories = categories;
        _tags = tags;
        _comments = comments;
        _media = media;
        _users = users;
        _tenantContext = tenantContext;
    }

    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories()
    {
        var userId = _tenantContext.IsResolved ? _tenantContext.UserId : Guid.Empty;
        return Ok(new { data = await _categories.GetAllAsync(userId) });
    }

    [HttpGet("tags")]
    public async Task<IActionResult> GetTags()
    {
        var userId = _tenantContext.IsResolved ? _tenantContext.UserId : Guid.Empty;
        return Ok(new { data = await _tags.GetAllAsync(userId) });
    }

    [HttpGet("comments")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public async Task<IActionResult> GetComments([FromQuery] Guid? postId, [FromQuery] int page = 1)
    {
        var result = await _comments.GetCommentsAsync(new CommentFilter
        {
            PostId = postId, Status = CommentStatus.Approved, Page = page, PageSize = 20
        });
        return Ok(new { data = result.Items, pagination = new { result.Page, result.PageSize, result.TotalItems, result.TotalPages } });
    }

    [HttpPost("comments")]
    public async Task<IActionResult> PostComment([FromBody] CommentRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.AuthorName) || string.IsNullOrWhiteSpace(req.AuthorEmail) || string.IsNullOrWhiteSpace(req.Content))
            return BadRequest(new { statusCode = 400, error = "Name, email, and content are required." });

        var comment = new Comment
        {
            PostId = req.PostId, AuthorName = req.AuthorName, AuthorEmail = req.AuthorEmail,
            Content = req.Content, Status = CommentStatus.Pending,
            AuthorIp = HttpContext.Connection.RemoteIpAddress?.ToString()
        };
        var id = await _comments.CreateAsync(comment);
        return Ok(new { data = new { id, status = "Pending" } });
    }

    [HttpPatch("comments/{id}/approve")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public async Task<IActionResult> ApproveComment(Guid id)
    {
        await _comments.UpdateStatusAsync(id, CommentStatus.Approved);
        return Ok(new { data = "Approved." });
    }

    [HttpDelete("comments/{id}")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public async Task<IActionResult> DeleteComment(Guid id)
    {
        await _comments.DeleteAsync(id);
        return Ok(new { data = "Deleted." });
    }

    [HttpPost("media")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public IActionResult UploadMedia()
        => RedirectToAction("Upload", "Media");

    [HttpGet("users/me")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public async Task<IActionResult> GetMe()
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var user = await _users.GetByIdAsync(userId);
        if (user == null) return NotFound();
        return Ok(new { data = new { user.Id, user.Email, user.DisplayName, user.Role, user.Bio, user.AvatarUrl } });
    }

    [HttpPut("users/me")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public async Task<IActionResult> UpdateMe([FromBody] UpdateMeRequest req)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var user = await _users.GetByIdAsync(userId);
        if (user == null) return NotFound();

        user.DisplayName = req.DisplayName ?? user.DisplayName;
        user.Bio = req.Bio ?? user.Bio;
        user.Website = req.Website ?? user.Website;
        await _users.UpdateAsync(user);
        return Ok(new { data = "Updated." });
    }
}

public record CommentRequest(Guid PostId, string AuthorName, string AuthorEmail, string Content);
public record UpdateMeRequest(string? DisplayName, string? Bio, string? Website);
