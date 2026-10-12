import Foundation

/// 内容条目响应
struct EntryResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let type: String?
    let authorType: String?
    let entityType: String?
    let entityId: Int?
    let channelId: Int?
    let circleId: Int?
    let placeId: Int?
    let longitude: String?
    let latitude: String?
    let country: String?
    let province: String?
    let city: String?
    let district: String?
    let place: String?
    let likes: Int?
    let replies: Int?
    let browses: Int?
    let favorites: Int?
    let plays: Int?
    let compositeOrders: Int?
    let hotOrders: Int?
    let newOrders: Int?
    let status: String?
    let releasedAt: String?
    let nickname: String?
    let avatar: String?
    let liked: Bool?
    let favorite: Bool?
    let timeDescription: String?
    
    /// 基础信息（可能是嵌套对象）
    let base: EntryBase?
    
    /// 作者显示名称
    var authorName: String {
        return nickname ?? "匿名用户"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
    
    /// 位置描述
    var locationText: String {
        var parts: [String] = []
        if let city = city, !city.isEmpty { parts.append(city) }
        if let place = place, !place.isEmpty { parts.append(place) }
        return parts.joined(separator: " · ")
    }
}

/// 内容基础信息
struct EntryBase: Codable {
    let title: String?
    let subtitle: String?
    let cover: String?
    let picture: [String]?
    let excerpt: String?
    let detail: String?
    let video: String?
}

/// 内容浏览类型
enum EntryOrderType: String {
    case latest = "latest"      // 最新
    case hot = "hot"            // 热门
    case recommend = "recommend" // 推荐
}
