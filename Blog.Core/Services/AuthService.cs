using Blog.Core.Domain;
using Blog.Core.Interfaces;
using System.Security.Cryptography;
using System.Text;

namespace Blog.Core.Services;

public class AuthService
{
    private readonly IUserRepository _users;

    public AuthService(IUserRepository users)
    {
        _users = users;
    }

    public string HashPassword(string password)
    {
        // PBKDF2 with SHA-256, 100k iterations
        using var rng = RandomNumberGenerator.Create();
        var salt = new byte[16];
        rng.GetBytes(salt);
        var hash = Rfc2898DeriveBytes.Pbkdf2(
            Encoding.UTF8.GetBytes(password), salt, 100_000, HashAlgorithmName.SHA256, 32);
        return $"pbkdf2${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";
    }

    public bool VerifyPassword(string password, string hash)
    {
        try
        {
            var parts = hash.Split('$');
            if (parts.Length != 3 || parts[0] != "pbkdf2") return false;
            var salt = Convert.FromBase64String(parts[1]);
            var storedHash = Convert.FromBase64String(parts[2]);
            var computed = Rfc2898DeriveBytes.Pbkdf2(
                Encoding.UTF8.GetBytes(password), salt, 100_000, HashAlgorithmName.SHA256, 32);
            return CryptographicOperations.FixedTimeEquals(computed, storedHash);
        }
        catch { return false; }
    }

    public async Task<(User? user, string? error)> ValidateLoginAsync(string email, string password)
    {
        var user = await _users.GetByEmailAsync(email);
        if (user == null) return (null, "Invalid email or password.");

        if (!user.IsActive) return (null, "Account is disabled.");

        if (!VerifyPassword(password, user.PasswordHash))
        {
            return (null, "Invalid email or password.");
        }

        return (user, null);
    }

}
