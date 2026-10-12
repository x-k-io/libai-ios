import Foundation

/// 认证服务
final class AuthService {
    static let shared = AuthService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 密码登录
    func login(loginName: String, password: String) async throws -> AccountToken {
        let body = LoginRequest(
            loginName: loginName,
            password: password,
            code: nil,
            channel: AppConfig.channel,
            type: "pwd_login"
        )
        return try await doLogin(body: body)
    }
    
    /// 验证码登录（手机号不存在时自动注册）
    func loginByCode(mobile: String, code: String) async throws -> AccountToken {
        let body = LoginRequest(
            loginName: mobile,
            password: nil,
            code: code,
            channel: AppConfig.channel,
            type: "message_login"
        )
        return try await doLogin(body: body)
    }
    
    /// 发送验证码（未登录状态，用于注册/验证码登录）
    func sendCode(mobile: String, type: String = "login") async throws {
        let body = SendCodeRequest(type: type, mobile: mobile)
        let _: Bool = try await client.request(
            endpoint: "/security/nonLogin/sendCode",
            method: .post,
            body: body,
            requiresAuth: false
        )
    }
    
    /// 登出
    func logout() async throws {
        guard let refreshToken = TokenManager.shared.refreshToken else { return }
        let body = LogoutRequest(refreshToken: refreshToken)
        let _: Bool = try await client.request(
            endpoint: "/security/logout",
            method: .post,
            body: body,
            requiresAuth: true
        )
        TokenManager.shared.clearTokens()
    }
    
    /// 获取当前用户信息
    func getAuthInfo() async throws -> KiteAccount {
        return try await client.request(endpoint: "/security/auth")
    }
    
    /// 刷新 Token
    func refreshAccessToken() async throws -> AccountToken {
        return try await client.refreshToken()
    }
    
    // MARK: - Private
    
    private func doLogin(body: LoginRequest) async throws -> AccountToken {
        let token: AccountToken = try await client.request(
            endpoint: "/security/login",
            method: .post,
            body: body,
            requiresAuth: false
        )
        if let accessToken = token.accessToken, let refreshToken = token.refreshToken {
            TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
        }
        return token
    }
}

/// 简化的账户信息（从 KiteAccount 映射）
struct KiteAccount: Codable {
    let id: Int?
    let nickname: String?
    let name: String?
    let avatar: String?
    let mobile: String?
    let email: String?
    let roles: [String]?
    let permissions: [String]?
    let status: String?
}

/// 发送验证码请求
struct SendCodeRequest: Codable {
    let type: String
    let mobile: String
}
