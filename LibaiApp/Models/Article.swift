import Foundation

/// 发布文章请求
struct ArticleRequest: Codable {
    let title: String
    let subtitle: String?
    let cover: String?
    let picture: [String]?
    let excerpt: String?
    let detail: String
    let video: String?
    let channelId: Int?
    let circleId: Int?
    let placeId: Int?
    let longitude: Double?
    let latitude: Double?
    let country: String?
    let province: String?
    let city: String?
    let district: String?
    let place: String?
}

/// 点赞请求
struct LikeRequest: Codable {
    let entityType: String
    let entityId: Int
    let entryId: Int?
}

/// 收藏请求
struct FavoriteRequest: Codable {
    let entryId: Int
}
