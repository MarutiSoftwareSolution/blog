namespace Blog.Core.Domain;

public class Comment
{
    public Guid Id { get; set; }
    public Guid PostId { get; set; }
    public string PostTitle { get; set; } = string.Empty;
    public string PostSlug { get; set; } = string.Empty;
    
    public Guid? MemberId { get; set; }
    public string? Html { get; set; }

    // Legacy fields (nullable now)
    public string? AuthorName { get; set; }
    public string? AuthorEmail { get; set; }
    public string? AuthorUrl { get; set; }
    public string? Content { get; set; }
    public string? AuthorIp { get; set; }

    public CommentStatus Status { get; set; } = CommentStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid? ParentId { get; set; }
    public List<Comment> Replies { get; set; } = new();
    public int Depth { get; set; } // Used for UI nesting level
}

public enum CommentStatus
{
    Pending,
    Approved
}
