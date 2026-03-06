namespace Blog.Core.Domain;

public class Revision
{
    public Guid Id { get; set; }
    public string EntityType { get; set; } = string.Empty; // Post, Page
    public Guid EntityId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public Guid AuthorId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
