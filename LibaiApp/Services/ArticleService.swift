import Foundation

/// 文章发布服务
final class ArticleService {
    static let shared = ArticleService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 发布文章
    func create(_ request: ArticleRequest) async throws -> Bool {
        return try await client.request(endpoint: "/articles", method: .post, body: request)
    }
    
    /// 更新文章
    func update(id: Int, _ request: ArticleRequest) async throws -> Bool {
        return try await client.request(endpoint: "/articles/\(id)", method: .put, body: request)
    }
}
