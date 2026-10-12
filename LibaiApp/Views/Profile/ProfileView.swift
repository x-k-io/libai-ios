import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 用户信息卡片
                VStack(spacing: 16) {
                    // 头像
                    AsyncImage(url: authManager.currentUser?.avatarURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    // 昵称
                    Text(authManager.currentUser?.displayName ?? "用户")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // 简介
                    if let introduction = authManager.currentUser?.introduction, !introduction.isEmpty {
                        Text(introduction)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 数据统计
                    HStack(spacing: 0) {
                        StatItemView(count: authManager.currentUser?.following ?? 0, title: "关注")
                        Divider().frame(height: 30)
                        StatItemView(count: authManager.currentUser?.followers ?? 0, title: "粉丝")
                        Divider().frame(height: 30)
                        StatItemView(count: authManager.currentUser?.entries ?? 0, title: "动态")
                        Divider().frame(height: 30)
                        StatItemView(count: authManager.currentUser?.likes ?? 0, title: "获赞")
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                // 功能菜单
                VStack(spacing: 0) {
                    MenuRow(icon: "doc.text", iconColor: .blue, title: "我的动态")
                    Divider().padding(.leading, 48)
                    MenuRow(icon: "bookmark", iconColor: .orange, title: "我的收藏")
                    Divider().padding(.leading, 48)
                    MenuRow(icon: "clock", iconColor: .green, title: "浏览历史")
                    Divider().padding(.leading, 48)
                    MenuRow(icon: "person.2", iconColor: .purple, title: "我的关注")
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                VStack(spacing: 0) {
                    MenuRow(icon: "pencil", iconColor: .blue, title: "编辑资料")
                    Divider().padding(.leading, 48)
                    MenuRow(icon: "lock", iconColor: .orange, title: "修改密码")
                    Divider().padding(.leading, 48)
                    MenuRow(icon: "hand.raised", iconColor: .red, title: "黑名单管理")
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                VStack(spacing: 0) {
                    MenuRow(icon: "gear", iconColor: .gray, title: "设置")
                    Divider().padding(.leading, 48)
                    MenuRow(icon: "info.circle", iconColor: .blue, title: "关于")
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // 退出登录
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("退出登录")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Spacer(minLength: 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.inline)
        .alert("退出登录", isPresented: $showingLogoutAlert) {
            Button("取消", role: .cancel) {}
            Button("确定", role: .destructive) {
                Task {
                    await authManager.logout()
                }
            }
        } message: {
            Text("确定要退出登录吗？")
        }
    }
}

// MARK: - 统计项
struct StatItemView: View {
    let count: Int
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 菜单行
struct MenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthManager.shared)
    }
}
