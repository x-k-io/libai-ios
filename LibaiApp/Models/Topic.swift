import Foundation

/// 话题响应
struct TopicResponse: Codable, Identifiable {
    let id: Int?
    let category: String?
    let icon: String?
    let name: String?
    let description: String?
    let orders: Int?
    let reads: Int?
    let mentions: Int?
    let authors: Int?
    let createdAt: String?
    let updatedAt: String?
    
    /// 图标 URL
    var iconURL: URL? {
        guard let icon = icon, !icon.isEmpty else { return nil }
        return URL(string: icon)
    }
}

/// 话题分类响应
struct TopicCategoryResponse: Codable, Identifiable {
    var id: String { category ?? UUID().uuidString }
    let category: String?
    let name: String?
    let topics: [TopicResponse]?
}

/// 创建话题请求
struct TopicRequest: Codable {
    let category: String
    let name: String
    let description: String?
    let icon: String?
}
