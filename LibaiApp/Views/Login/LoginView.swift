import SwiftUI

/// 登录方式
enum LoginMode: String {
    case password = "密码登录"
    case code = "验证码登录"
}

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var mode: LoginMode = .code
    @State private var mobile = ""
    @State private var password = ""
    @State private var code = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var countdown = 0
    @State private var showApiSettings = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.36, green: 0.55, blue: 0.95),
                        Color(red: 0.55, green: 0.42, blue: 0.88),
                        Color(red: 0.78, green: 0.38, blue: 0.72)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo 区域
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("Libai")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("分享你的生活")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 90)
                    .padding(.bottom, 50)
                    
                    // 白色卡片
                    VStack(spacing: 0) {
                        // 登录方式切换
                        HStack(spacing: 0) {
                            ForEach([LoginMode.password, LoginMode.code], id: \.self) { item in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        mode = item
                                    }
                                } label: {
                                    Text(item.rawValue)
                                        .font(.system(size: 15, weight: mode == item ? .semibold : .regular))
                                        .foregroundColor(mode == item ? .white : .gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            mode == item
                                            ? Color(red: 0.36, green: 0.55, blue: 0.95)
                                            : Color.clear
                                        )
                                        .cornerRadius(mode == item ? 8 : 0)
                                }
                            }
                        }
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        // 输入区域
                        VStack(spacing: 16) {
                            // 手机号
                            HStack(spacing: 10) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                
                                TextField("请输入手机号", text: $mobile)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            if mode == .password {
                                // 密码输入
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    
                                    SecureField("请输入密码", text: $password)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            } else {
                                // 验证码输入 + 发送按钮
                                HStack(spacing: 12) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "shield.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                            .frame(width: 24)
                                        
                                        TextField("请输入验证码", text: $code)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 15))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    
                                    Button(action: sendCode) {
                                        Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(countdown > 0 ? .gray : .white)
                                            .frame(width: 90, height: 46)
                                            .background(
                                                countdown > 0
                                                ? Color(.systemGray5)
                                                : (mobile.isEmpty ? Color.gray : Color(red: 0.36, green: 0.55, blue: 0.95))
                                            )
                                            .cornerRadius(12)
                                    }
                                    .disabled(mobile.isEmpty || countdown > 0)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        // 登录按钮
                        Button(action: handleLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(mode == .password ? "登 录" : "登 录 / 注 册")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.36, green: 0.55, blue: 0.95),
                                        Color(red: 0.55, green: 0.42, blue: 0.88)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(26)
                            .shadow(color: Color(red: 0.36, green: 0.55, blue: 0.95).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        .disabled(!canLogin || isLoading)
                        .opacity(canLogin ? 1 : 0.5)
                        
                        // 底部链接
                        VStack(spacing: 10) {
                            if mode == .password {
                                Button("忘记密码？") { }
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.95))
                            }
                            
                            HStack(spacing: 4) {
                                Text("登录即代表同意")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Button("《用户协议》") { }
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.95))
                                Text("和")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Button("《隐私政策》") { }
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.95))
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 28)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // API 设置入口
                    Button(action: { showApiSettings = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 11))
                            Text("API 设置")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                if countdown > 0 {
                    countdown -= 1
                }
            }
            .alert("提示", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showApiSettings) {
                ApiSettingsView()
            }
        }
    }
    
    private var canLogin: Bool {
        if mobile.isEmpty { return false }
        if mode == .password {
            return !password.isEmpty
        } else {
            return !code.isEmpty
        }
    }
    
    private func handleLogin() {
        isLoading = true
        
        Task {
            let success: Bool
            if mode == .password {
                success = await authManager.login(loginName: mobile, password: password)
            } else {
                success = await authManager.loginByCode(mobile: mobile, code: code)
            }
            isLoading = false
            
            if !success {
                errorMessage = authManager.errorMessage ?? "操作失败"
                showError = true
            }
        }
    }
    
    private func sendCode() {
        Task {
            let success = await authManager.sendCode(mobile: mobile)
            if success {
                countdown = 60
            } else {
                errorMessage = authManager.errorMessage ?? "发送验证码失败"
                showError = true
            }
        }
    }
}

// MARK: - API 设置页面
struct ApiSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var apiURL = AppConfig.baseURL
    
    var body: some View {
        NavigationStack {
            Form {
                Section("API 地址") {
                    TextField("http://192.168.1.100:11010/api/app/v1", text: $apiURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.system(size: 14))
                }
                
                Section {
                    Button("恢复默认") {
                        AppConfig.resetToDefault()
                        apiURL = AppConfig.baseURL
                    }
                    .foregroundColor(.red)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("使用说明")
                            .font(.system(size: 14, weight: .medium))
                        Text("• 模拟器使用 localhost 即可")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("• 真机需要填写 Mac 的局域网 IP")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("• 格式：http://IP:端口/api/app/v1")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("API 设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        AppConfig.baseURL = apiURL
                        dismiss()
                    }
                    .disabled(apiURL.isEmpty)
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
