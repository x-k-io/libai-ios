import Foundation

/// 内容服务
final class EntryService {
    static let shared = EntryService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 获取内容详情
    func getById(id: Int) async throws -> EntryResponse {
        return try await client.request(endpoint: "/entries/\(id)", requiresAuth: true)
    }
    
    /// 探索 - 推荐内容
    func explore(orderType: String, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/explore",
            parameters: ["orderType": orderType, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: true
        )
    }
    
    /// 关注的人的内容
    func followers(lastId: Int? = nil, pageSize: Int = 10) async throws -> [EntryResponse] {
        var params: [String: Any] = ["pageSize": pageSize]
        if let lastId = lastId { params["lastId"] = lastId }
        return try await client.request(endpoint: "/entries/followers", parameters: params)
    }
    
    /// 我的内容
    func me(pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/me",
            parameters: ["pageNum": pageNum, "pageSize": pageSize]
        )
    }
    
    /// 他人的内容
    func their(accountId: Int, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/their",
            parameters: ["accountId": accountId, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: true
        )
    }
    
    /// 浏览历史
    func browse(pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/browse",
            parameters: ["pageNum": pageNum, "pageSize": pageSize]
        )
    }
    
    /// 收藏的内容
    func favorite(pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/favorite",
            parameters: ["pageNum": pageNum, "pageSize": pageSize]
        )
    }
    
    /// 按频道获取
    func channels(channelId: Int, orderType: String, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/channels",
            parameters: ["channelId": channelId, "orderType": orderType, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: true
        )
    }
    
    /// 按圈子获取
    func circles(circleId: Int, orderType: String, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/circles",
            parameters: ["circleId": circleId, "orderType": orderType, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: true
        )
    }
    
    /// 按位置获取
    func location(city: String, orderType: String, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<EntryResponse> {
        return try await client.requestPage(
            endpoint: "/entries/location",
            parameters: ["city": city, "orderType": orderType, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: true
        )
    }
    
    /// 点赞
    func like(entityType: String, entityId: Int, entryId: Int? = nil) async throws -> Bool {
        let body = LikeRequest(entityType: entityType, entityId: entityId, entryId: entryId)
        return try await client.request(endpoint: "/likes", method: .post, body: body)
    }
    
    /// 取消点赞
    func cancelLike(entryId: Int) async throws -> Bool {
        return try await client.request(endpoint: "/likes", method: .delete, parameters: ["entryId": entryId])
    }
    
    /// 收藏
    func favorite(entryId: Int) async throws -> Bool {
        let body = FavoriteRequest(entryId: entryId)
        return try await client.request(endpoint: "/favorites", method: .post, body: body)
    }
    
    /// 取消收藏
    func cancelFavorite(entryId: Int) async throws -> Bool {
        return try await client.request(endpoint: "/favorites", method: .delete, parameters: ["entryId": entryId])
    }
}
