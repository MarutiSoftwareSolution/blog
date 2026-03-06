using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Dapper;

namespace Blog.Infrastructure.Data.Repositories;

public class RevisionRepository : IRevisionRepository
{
    private readonly DapperContext _ctx;
    public RevisionRepository(DapperContext ctx) => _ctx = ctx;

    public async Task<List<Revision>> GetByEntityAsync(string entityType, Guid entityId)
    {
        using var conn = _ctx.CreateConnection();
        return (await conn.QueryAsync<Revision>(
            "SELECT * FROM Revisions WHERE EntityType = @Type AND EntityId = @Id ORDER BY CreatedAt DESC",
            new { Type = entityType, Id = entityId })).ToList();
    }

    public async Task<Revision?> GetByIdAsync(Guid id)
    {
        using var conn = _ctx.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<Revision>(
            "SELECT * FROM Revisions WHERE Id = @Id", new { Id = id });
    }

    public async Task<Guid> CreateAsync(Revision revision)
    {
        using var conn = _ctx.CreateConnection();
        if (revision.Id == Guid.Empty) revision.Id = Guid.NewGuid();
        return await conn.ExecuteScalarAsync<Guid>(@"
            INSERT INTO Revisions (Id, EntityType, EntityId, Title, Content, AuthorId, CreatedAt)
            OUTPUT INSERTED.Id
            VALUES (@Id, @EntityType, @EntityId, @Title, @Content, @AuthorId, @CreatedAt)",
            new { revision.Id, revision.EntityType, revision.EntityId, revision.Title, revision.Content, revision.AuthorId,
                  CreatedAt = DateTime.Now });
    }

    public async Task DeleteAsync(Guid id)
    {
        using var conn = _ctx.CreateConnection();
        await conn.ExecuteAsync("DELETE FROM Revisions WHERE Id = @Id", new { Id = id });
    }
}
