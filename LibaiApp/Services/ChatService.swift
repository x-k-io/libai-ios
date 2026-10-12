import Foundation

/// 聊天服务
final class ChatService {
    static let shared = ChatService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 获取聊天列表
    func getChatList() async throws -> [ChatResponse] {
        return try await client.request(endpoint: "/chats")
    }
    
    /// 创建聊天
    func createChat(friendId: Int) async throws -> ChatResponse {
        let body = ChatRequest(friendId: friendId)
        return try await client.request(endpoint: "/chats", method: .post, body: body)
    }
    
    /// 删除聊天
    func deleteChat(id: Int) async throws {
        let _: Bool = try await client.request(endpoint: "/chats/\(id)", method: .delete)
    }
    
    /// 发送消息
    func sendMessage(chatId: Int, type: String = "text", content: String) async throws {
        let body = MessageRequest(type: type, content: content)
        let _: Bool = try await client.request(
            endpoint: "/chats/\(chatId)/messages",
            method: .post,
            body: body
        )
    }
    
    /// 获取消息列表
    func getMessages(chatId: Int, lastRefreshTime: String) async throws -> [MessageResponse] {
        return try await client.request(
            endpoint: "/chats/\(chatId)/messages",
            parameters: ["lastRefreshTime": lastRefreshTime]
        )
    }
    
    /// 获取历史消息
    func getMessageRecords(chatId: Int, lastId: Int? = nil, limit: Int = 10) async throws -> [MessageResponse] {
        var params: [String: Any] = ["limit": limit]
        if let lastId = lastId { params["lastId"] = lastId }
        return try await client.request(
            endpoint: "/chats/\(chatId)/message-records",
            parameters: params
        )
    }
}

/// 通知服务
final class NoticeService {
    static let shared = NoticeService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 获取通知列表
    func getNotices(types: [String]? = nil, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<NoticeResponse> {
        var params: [String: Any] = ["pageNum": pageNum, "pageSize": pageSize]
        if let types = types, !types.isEmpty {
            params["types"] = types.joined(separator: ",")
        }
        return try await client.requestPage(endpoint: "/notices", parameters: params)
    }
    
    /// 获取未读通知
    func unread() async throws -> NoticeRemindResponse {
        return try await client.request(endpoint: "/notices/un-read")
    }
}
