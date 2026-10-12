import Foundation

/// 通知响应
struct NoticeResponse: Codable, Identifiable {
    let id: Int?
    let type: String?
    let receiveId: Int?
    let detail: String?
    let createdAt: String?
    
    /// 通知类型描述
    var typeDescription: String {
        switch type {
        case "like": return "赞"
        case "comment": return "评论"
        case "reply": return "回复"
        case "follow": return "关注"
        case "system": return "系统"
        default: return "通知"
        }
    }
}

/// 未读通知提醒响应
struct NoticeRemindResponse: Codable, Identifiable {
    let id: Int?
    let accountId: Int?
    let system: Int?
    let likes: Int?
    let forwards: Int?
    let replies: Int?
    let follows: Int?
    let createdAt: String?
    
    /// 总未读数
    var totalUnread: Int {
        return (system ?? 0) + (likes ?? 0) + (forwards ?? 0) + (replies ?? 0) + (follows ?? 0)
    }
}
