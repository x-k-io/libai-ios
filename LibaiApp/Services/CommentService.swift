import Foundation

/// 评论服务
final class CommentService {
    static let shared = CommentService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 获取评论列表
    func getComments(entryId: Int, pageNum: Int = 0, pageSize: Int = 10) async throws -> PageResult<CommentResponse> {
        return try await client.requestPage(
            endpoint: "/comments",
            parameters: ["entryId": entryId, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: false
        )
    }
    
    /// 发表评论
    func comment(entryId: Int, content: String) async throws -> CommentResponse {
        let body = CommentRequest(entryId: entryId, content: content)
        return try await client.request(endpoint: "/comments", method: .post, body: body)
    }
    
    /// 获取回复列表
    func getReplies(commentId: Int, pageNum: Int = 0, pageSize: Int = 10) async throws -> PageResult<ReplyResponse> {
        return try await client.requestPage(
            endpoint: "/replies",
            parameters: ["commentId": commentId, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: false
        )
    }
    
    /// 发表回复
    func reply(entryId: Int, commentId: Int, toAccountId: Int? = nil, content: String) async throws -> ReplyResponse {
        let body = ReplyRequest(entryId: entryId, commentId: commentId, toAccountId: toAccountId, content: content)
        return try await client.request(endpoint: "/replies", method: .post, body: body)
    }
}
