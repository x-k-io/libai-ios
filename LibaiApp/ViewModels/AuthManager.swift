import Foundation
import SwiftUI

/// 认证管理器
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: AccountResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    private let accountService = AccountService.shared
    
    private init() {
        isLoggedIn = TokenManager.shared.isLoggedIn
        if isLoggedIn {
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    /// 密码登录
    func login(loginName: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.login(loginName: loginName, password: password)
            isLoggedIn = true
            await loadCurrentUser()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// 验证码登录
    func loginByCode(mobile: String, code: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.loginByCode(mobile: mobile, code: code)
            isLoggedIn = true
            await loadCurrentUser()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// 发送验证码
    func sendCode(mobile: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.sendCode(mobile: mobile)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// 登出
    func logout() async {
        do {
            try await authService.logout()
        } catch {
            print("登出失败: \(error)")
        }
        isLoggedIn = false
        currentUser = nil
        TokenManager.shared.clearTokens()
    }
    
    /// 加载当前用户信息
    func loadCurrentUser() async {
        do {
            currentUser = try await accountService.me()
        } catch {
            print("加载用户信息失败: \(error)")
        }
    }
    
    /// 刷新用户信息
    func refreshUser() async {
        await loadCurrentUser()
    }
}
