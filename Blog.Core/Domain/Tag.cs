namespace Blog.Core.Domain;

public class Tag
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public Guid AuthorId { get; set; }
    public int PostCount { get; set; }
}
