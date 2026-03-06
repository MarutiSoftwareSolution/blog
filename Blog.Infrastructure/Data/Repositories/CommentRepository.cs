using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Dapper;

namespace Blog.Infrastructure.Data.Repositories;

public class CommentRepository : ICommentRepository
{
    private readonly DapperContext _ctx;
    public CommentRepository(DapperContext ctx) => _ctx = ctx;

    public async Task<PagedResult<Comment>> GetCommentsAsync(CommentFilter filter)
    {
        using var conn = _ctx.CreateConnection();
        var where = new List<string> { "1=1" };
        var p = new DynamicParameters();

        if (filter.PostId.HasValue) { where.Add("c.PostId = @PostId"); p.Add("PostId", filter.PostId.Value); }
        if (filter.Status.HasValue) { where.Add("c.Status = @Status"); p.Add("Status", filter.Status.Value.ToString()); }
        if (filter.PostAuthorId.HasValue)
        {
            where.Add("EXISTS (SELECT 1 FROM Posts p WHERE p.Id = c.PostId AND p.AuthorId = @PostAuthorId)");
            p.Add("PostAuthorId", filter.PostAuthorId.Value);
        }

        var whereClause = string.Join(" AND ", where);
        var offset = (filter.Page - 1) * filter.PageSize;
        p.Add("PageSize", filter.PageSize);
        p.Add("Offset", offset);

        var total = await conn.ExecuteScalarAsync<int>($"SELECT COUNT(*) FROM Comments c WHERE {whereClause}", p);
        var items = (await conn.QueryAsync<Comment>($@"
            SELECT c.*, p.Title as PostTitle, p.Slug as PostSlug FROM Comments c
            LEFT JOIN Posts p ON p.Id = c.PostId
            WHERE {whereClause}
            ORDER BY c.CreatedAt DESC
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY", p)).ToList();

        return new PagedResult<Comment> { Items = items, TotalItems = total, Page = filter.Page, PageSize = filter.PageSize };
    }

    public async Task<Comment?> GetByIdAsync(Guid id)
    {
        using var conn = _ctx.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<Comment>(
            "SELECT c.*, p.Title as PostTitle, p.Slug as PostSlug FROM Comments c LEFT JOIN Posts p ON p.Id = c.PostId WHERE c.Id = @Id",
            new { Id = id });
    }

    public async Task<Guid> CreateAsync(Comment comment)
    {
        using var conn = _ctx.CreateConnection();
        if (comment.Id == Guid.Empty) comment.Id = Guid.NewGuid();
        return await conn.ExecuteScalarAsync<Guid>(@"
            INSERT INTO Comments (Id, PostId, AuthorName, AuthorEmail, AuthorUrl, AuthorIp, Content, Status, ParentId, CreatedAt)
            OUTPUT INSERTED.Id
            VALUES (@Id, @PostId, @AuthorName, @AuthorEmail, @AuthorUrl, @AuthorIp, @Content, @Status, @ParentId, @CreatedAt)",
            new { comment.Id, comment.PostId, comment.AuthorName, comment.AuthorEmail, comment.AuthorUrl, comment.AuthorIp,
                  comment.Content, Status = comment.Status.ToString(), comment.ParentId,
                  CreatedAt = DateTime.Now });
    }

    public async Task UpdateStatusAsync(Guid id, CommentStatus status)
    {
        using var conn = _ctx.CreateConnection();
        await conn.ExecuteAsync("UPDATE Comments SET Status = @Status WHERE Id = @Id",
            new { Status = status.ToString(), Id = id });
    }

    public async Task DeleteAsync(Guid id)
    {
        using var conn = _ctx.CreateConnection();
        await conn.ExecuteAsync("DELETE FROM Comments WHERE Id = @Id", new { Id = id });
    }

    public async Task<int> GetPendingCountAsync(Guid? postAuthorId = null)
    {
        using var conn = _ctx.CreateConnection();
        var sql = "SELECT COUNT(*) FROM Comments c WHERE c.Status = 'Pending'";
        if (postAuthorId.HasValue)
        {
            sql += " AND EXISTS (SELECT 1 FROM Posts p WHERE p.Id = c.PostId AND p.AuthorId = @PostAuthorId)";
        }
        return await conn.ExecuteScalarAsync<int>(sql, new { PostAuthorId = postAuthorId });
    }

    public async Task<List<Comment>> GetApprovedForPostAsync(Guid postId)
    {
        using var conn = _ctx.CreateConnection();
        return (await conn.QueryAsync<Comment>(@"
            SELECT * FROM Comments WHERE PostId = @PostId AND Status = 'Approved'
            ORDER BY CreatedAt ASC", new { PostId = postId })).ToList();
    }
}
