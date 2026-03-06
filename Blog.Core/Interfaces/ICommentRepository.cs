using Blog.Core.Domain;

namespace Blog.Core.Interfaces;

public class CommentFilter
{
    public Guid? PostId { get; set; }
    public Guid? PostAuthorId { get; set; }
    public CommentStatus? Status { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}

public interface ICommentRepository
{
    Task<PagedResult<Comment>> GetCommentsAsync(CommentFilter filter);
    Task<Comment?> GetByIdAsync(Guid id);
    Task<Guid> CreateAsync(Comment comment);
    Task UpdateStatusAsync(Guid id, CommentStatus status);
    Task DeleteAsync(Guid id);
    Task<int> GetPendingCountAsync(Guid? postAuthorId = null);
    Task<List<Comment>> GetApprovedForPostAsync(Guid postId);
}
