using Blog.Core.Domain;
using Blog.Core.Interfaces;
using Dapper;

namespace Blog.Infrastructure.Data.Repositories;

public class MediaRepository : IMediaRepository
{
    private readonly DapperContext _ctx;
    public MediaRepository(DapperContext ctx) => _ctx = ctx;

    public async Task<List<Media>> GetAllAsync(Guid uploadedBy, int page = 1, int pageSize = 50)
    {
        using var conn = _ctx.CreateConnection();
        var offset = (page - 1) * pageSize;
        return (await conn.QueryAsync<Media>(@"
            SELECT * FROM Media
            WHERE UploadedBy = @UploadedBy
            ORDER BY CreatedAt DESC
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY",
            new { UploadedBy = uploadedBy, Offset = offset, PageSize = pageSize })).ToList();
    }

    public async Task<Media?> GetByIdAsync(Guid id, Guid? uploadedBy = null)
    {
        using var conn = _ctx.CreateConnection();
        var sql = "SELECT * FROM Media WHERE Id = @Id";
        if (uploadedBy.HasValue) sql += " AND UploadedBy = @UploadedBy";
        return await conn.QueryFirstOrDefaultAsync<Media>(sql, new { Id = id, UploadedBy = uploadedBy });
    }

    public async Task<Guid> CreateAsync(Media media)
    {
        using var conn = _ctx.CreateConnection();
        if (media.Id == Guid.Empty) media.Id = Guid.NewGuid();
        return await conn.ExecuteScalarAsync<Guid>(@"
            INSERT INTO Media (Id, FileName, OriginalFileName, FilePath, Url, ContentType, FileSize, Width, Height, AltText, Caption, UploadedBy, CreatedAt)
            OUTPUT INSERTED.Id
            VALUES (@Id, @FileName, @OriginalFileName, @FilePath, @Url, @ContentType, @FileSize, @Width, @Height, @AltText, @Caption, @UploadedBy, @CreatedAt)",
            new { media.Id, media.FileName, media.OriginalFileName, media.FilePath, media.Url, media.ContentType,
                  media.FileSize, media.Width, media.Height, media.AltText, media.Caption, media.UploadedBy,
                  CreatedAt = DateTime.Now });
    }

    public async Task DeleteAsync(Guid id, Guid? uploadedBy = null)
    {
        using var conn = _ctx.CreateConnection();
        var sql = "DELETE FROM Media WHERE Id = @Id";
        if (uploadedBy.HasValue) sql += " AND UploadedBy = @UploadedBy";
        await conn.ExecuteAsync(sql, new { Id = id, UploadedBy = uploadedBy });
    }

    public async Task<int> GetTotalCountAsync(Guid? uploadedBy = null)
    {
        using var conn = _ctx.CreateConnection();
        var sql = "SELECT COUNT(*) FROM Media";
        if (uploadedBy.HasValue) sql += " WHERE UploadedBy = @UploadedBy";
        return await conn.ExecuteScalarAsync<int>(sql, new { UploadedBy = uploadedBy });
    }
}
