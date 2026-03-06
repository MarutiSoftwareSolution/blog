namespace Blog.Core.Domain;

public class Role
{
    public Guid Id { get; set; }
    public Guid Uuid { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}
