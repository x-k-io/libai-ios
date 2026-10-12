import Foundation

/// 社交服务
final class FriendService {
    static let shared = FriendService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 关注
    func follow(friendId: Int) async throws {
        let _: Bool = try await client.request(
            endpoint: "/friends",
            method: .post,
            parameters: ["friendId": friendId]
        )
    }
    
    /// 取消关注
    func cancelFollow(friendId: Int) async throws {
        let _: Bool = try await client.request(
            endpoint: "/friends",
            method: .delete,
            parameters: ["friendId": friendId]
        )
    }
    
    /// 获取粉丝列表
    func getFollowers(accountId: Int) async throws -> [FriendResponse] {
        return try await client.request(
            endpoint: "/friends/followers",
            parameters: ["accountId": accountId],
            requiresAuth: false
        )
    }
    
    /// 获取关注列表
    func getFollowing(accountId: Int, pageNum: Int = 1, pageSize: Int = 10) async throws -> PageResult<FriendResponse> {
        return try await client.requestPage(
            endpoint: "/friends/following",
            parameters: ["accountId": accountId, "pageNum": pageNum, "pageSize": pageSize],
            requiresAuth: false
        )
    }
    
    /// 通讯录
    func getAddressBooks() async throws -> [String: [FriendResponse]] {
        return try await client.request(endpoint: "/friends/address-books")
    }
    
    /// 推荐好友
    func recommendFriends() async throws -> [RecommendFriendResponse] {
        return try await client.request(endpoint: "/friends/recommend")
    }
    
    /// 推荐（好友+内容）
    func recommend() async throws -> RecommendResponse {
        return try await client.request(endpoint: "/friends/recommend1")
    }
}

/// 话题服务
final class TopicService {
    static let shared = TopicService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 获取话题分类列表
    func getTopics() async throws -> [TopicCategoryResponse] {
        return try await client.request(endpoint: "/topics")
    }
    
    /// 搜索话题
    func search(name: String) async throws -> [TopicResponse] {
        return try await client.request(
            endpoint: "/topics/search",
            parameters: ["name": name]
        )
    }
    
    /// 创建话题
    func create(request: TopicRequest) async throws -> Bool {
        return try await client.request(endpoint: "/topics", method: .post, body: request)
    }
}

/// 黑名单服务
final class BlacklistService {
    static let shared = BlacklistService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 拉黑
    func blacklist(theirId: Int) async throws {
        let _: Bool = try await client.request(
            endpoint: "/blacklists",
            method: .post,
            parameters: ["theirId": theirId]
        )
    }
    
    /// 取消拉黑
    func cancel(theirId: Int) async throws {
        let _: Bool = try await client.request(
            endpoint: "/blacklists",
            method: .delete,
            parameters: ["theirId": theirId]
        )
    }
    
    /// 获取黑名单列表
    func getBlacklist() async throws -> [BlacklistResponse] {
        return try await client.request(endpoint: "/blacklists")
    }
}
