import Foundation

/// 通用 API 响应包装
struct APIResponse<T: Codable>: Codable {
    let code: Int?
    let message: String?
    let data: T?
    let pagination: Pagination?
    
    /// 是否成功
    var isSuccess: Bool {
        return code == 1
    }
    
    /// 分页信息
    struct Pagination: Codable {
        let pageCount: Int?
        let total: Int?
    }
}

/// 分页结果
struct PageResult<T: Codable>: Codable {
    let records: [T]?
    let pageCount: Int?
    let total: Int?
}

/// API 错误
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodeError(Error)
    case businessError(code: Int, message: String)
    case tokenExpired
    case noPermission
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .decodeError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .businessError(_, let message):
            return message
        case .tokenExpired:
            return "登录已过期，请重新登录"
        case .noPermission:
            return "暂无操作权限"
        }
    }
}
