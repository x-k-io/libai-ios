import Foundation

/// 聊天会话响应
struct ChatResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let nickname: String?
    let avatar: String?
    let relation: String?
    let unreadCount: Int?
    let lastMessageId: Int?
    let lastContent: String?
    let lastedAt: String?
    let createdAt: String?
    
    /// 显示名称
    var displayName: String {
        return nickname ?? "聊天"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
    
    /// 最后消息时间描述
    var lastTimeDescription: String {
        guard let lastedAt = lastedAt else { return "" }
        return formatTime(lastedAt)
    }
    
    private func formatTime(_ timeStr: String) -> String {
        // 简单的时间格式化，实际使用时需要更完善的逻辑
        return timeStr
    }
}

/// 消息响应
struct MessageResponse: Codable, Identifiable {
    let id: Int?
    let type: String?
    let chatId: Int?
    let accountId: Int?
    let content: String?
    let createdAt: String?
    let nickname: String?
    let avatar: String?
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}

/// 创建聊天请求
struct ChatRequest: Codable {
    let friendId: Int
}

/// 发送消息请求
struct MessageRequest: Codable {
    let type: String
    let content: String
}
