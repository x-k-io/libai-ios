import Foundation

/// 账户服务
final class AccountService {
    static let shared = AccountService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// 获取自己的信息
    func me() async throws -> AccountResponse {
        return try await client.request(endpoint: "/accounts/me")
    }
    
    /// 获取他人信息
    func their(theirId: Int) async throws -> AccountResponse {
        return try await client.request(
            endpoint: "/accounts/their",
            parameters: ["theirId": theirId]
        )
    }
    
    /// 更新账户信息
    func updateAccount(_ request: UpdateAccountRequest) async throws -> Bool {
        return try await client.request(
            endpoint: "/accounts/updateAccountInfo",
            method: .put,
            body: request
        )
    }
    
    /// 修改密码
    func updatePassword(oldPassword: String, newPassword: String) async throws -> Bool {
        let body = UpdatePasswordRequest(oldPassword: oldPassword, newPassword: newPassword)
        return try await client.request(
            endpoint: "/accounts/updatePassword",
            method: .put,
            body: body
        )
    }
    
    /// 重置密码
    func resetPassword(mobile: String, newPassword: String, code: String) async throws -> Bool {
        let body = ResetPasswordRequest(mobile: mobile, newPassword: newPassword, code: code)
        return try await client.request(
            endpoint: "/accounts/resetPassword",
            method: .post,
            body: body,
            requiresAuth: false
        )
    }
}
