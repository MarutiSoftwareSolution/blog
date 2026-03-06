namespace Blog.Core.Domain;

public class Permission
{
    public Guid Id { get; set; }
    public Guid Uuid { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string ActionType { get; set; } = string.Empty;
    public string ObjectType { get; set; } = string.Empty;
}
