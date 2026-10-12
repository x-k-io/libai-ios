import Foundation

/// 应用配置
enum AppConfig {
    /// 请求超时时间
    static let timeoutInterval: TimeInterval = 30
    
    /// 应用渠道标识
    static let channel = "app"
    
    /// 默认 API 地址
    private static let defaultBaseURL = "http://localhost:11010/api/app/v1"
    
    /// API 基础地址（支持运行时修改）
    static var baseURL: String {
        get {
            return UserDefaults.standard.string(forKey: "apiBaseURL") ?? defaultBaseURL
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apiBaseURL")
        }
    }
    
    /// 恢复默认地址
    static func resetToDefault() {
        UserDefaults.standard.removeObject(forKey: "apiBaseURL")
    }
}
