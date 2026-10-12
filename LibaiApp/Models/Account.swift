import Foundation

/// 账户令牌响应
struct AccountToken: Codable {
    let accessToken: String?
    let refreshToken: String?
    let accessExpire: Int64?
}

/// 账户信息响应
struct AccountResponse: Codable, Identifiable {
    let id: Int64?
    let type: String?
    let mobile: String?
    let name: String?
    let nickname: String?
    let initials: String?
    let avatar: String?
    let gender: String?
    let birthday: String?
    let country: String?
    let province: String?
    let city: String?
    let district: String?
    let introduction: String?
    let following: Int?
    let followers: Int?
    let entries: Int?
    let replies: Int?
    let likes: Int?
    let browses: Int?
    let plays: Int?
    let registeredAt: String?
    let status: String?
    
    /// 显示名称
    var displayName: String {
        return nickname ?? name ?? "用户\(id ?? 0)"
    }
    
    /// 头像 URL
    var avatarURL: URL? {
        guard let avatar = avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}

/// 更新账户请求
struct UpdateAccountRequest: Codable {
    var nickname: String?
    var avatar: String?
    var gender: String?
    var birthday: String?
    var introduction: String?
    var country: String?
    var province: String?
    var city: String?
    var district: String?
}

/// 更新密码请求
struct UpdatePasswordRequest: Codable {
    let oldPassword: String
    let newPassword: String
}

/// 重置密码请求
struct ResetPasswordRequest: Codable {
    let mobile: String
    let newPassword: String
    let code: String
}

/// 登录请求
struct LoginRequest: Codable {
    let loginName: String?
    let password: String?
    let code: String?
    let channel: String
    let type: String
}

/// 刷新令牌请求
struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

/// 登出请求
struct LogoutRequest: Codable {
    let refreshToken: String
}
