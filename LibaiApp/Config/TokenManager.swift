import Foundation

/// Token 管理器 - 负责存储和读取访问令牌
final class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "libai_access_token"
    private let refreshTokenKey = "libai_refresh_token"
    
    private init() {}
    
    /// 访问令牌
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: accessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: accessTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 刷新令牌
    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: refreshTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: refreshTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 保存令牌
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    /// 清除令牌
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        UserDefaults.standard.synchronize()
    }
    
    /// 是否已登录
    var isLoggedIn: Bool {
        return accessToken != nil && !accessToken!.isEmpty && refreshToken != nil && !refreshToken!.isEmpty
    }
}
