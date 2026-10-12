import Foundation

/// 评论响应
struct CommentResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let entityType: String?
    let entityId: Int?
    let entryId: Int?
    let content: String?
    let likes: Int?
    let replies: Int?
    let authored: Bool?
    let nickname: String?
    let avatar: String?
    let liked: Bool?
    let timeDescription: String?
    
    /// 作者显示名称
    var authorName: String {
        return nickname ?? "匿名用户"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}

/// 发布评论请求
struct CommentRequest: Codable {
    let entryId: Int
    let content: String
}

/// 回复响应
struct ReplyResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let entityType: String?
    let entityId: Int?
    let entryId: Int?
    let commentId: Int?
    let toAccountId: Int?
    let content: String?
    let likes: Int?
    let authored: Bool?
    let nickname: String?
    let avatar: String?
    let toNickname: String?
    let liked: Bool?
    let timeDescription: String?
    
    /// 作者显示名称
    var authorName: String {
        return nickname ?? "匿名用户"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
    
    /// 回复目标
    var replyToText: String? {
        guard let toNickname = toNickname else { return nil }
        return "回复 @\(toNickname)"
    }
}

/// 发布回复请求
struct ReplyRequest: Codable {
    let entryId: Int
    let commentId: Int
    let toAccountId: Int?
    let content: String
}
