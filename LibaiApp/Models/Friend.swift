import Foundation

/// 好友/关注响应
struct FriendResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let friendId: Int?
    let friendStatus: String?
    let createdAt: String?
    let nickname: String?
    let avatar: String?
    let initials: String?
    let followsCount: Int?
    
    /// 显示名称
    var displayName: String {
        return nickname ?? "用户\(friendId ?? 0)"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}

/// 推荐好友响应
struct RecommendFriendResponse: Codable, Identifiable {
    var id: Int? { accountId }
    let accountId: Int?
    let nickname: String?
    let avatar: String?
    
    /// 显示名称
    var displayName: String {
        return nickname ?? "用户\(accountId ?? 0)"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}

/// 推荐响应（包含推荐好友和推荐内容）
struct RecommendResponse: Codable {
    let friends: [RecommendFriendResponse]?
    let entries: [EntryResponse]?
}

/// 黑名单响应
struct BlacklistResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let theirId: Int?
    let createdAt: String?
    let nickname: String?
    let avatar: String?
    
    /// 显示名称
    var displayName: String {
        return nickname ?? "用户\(theirId ?? 0)"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}
