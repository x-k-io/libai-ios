import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var unreadCount = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            NavigationStack {
                HomeView()
                    .environmentObject(authManager)
            }
            .tabItem {
                Label("首页", systemImage: "house")
            }
            .tag(0)
            
            // 发现
            NavigationStack {
                ExploreView()
                    .environmentObject(authManager)
            }
            .tabItem {
                Label("发现", systemImage: "safari")
            }
            .tag(1)
            
            // 消息
            NavigationStack {
                MessageView()
                    .environmentObject(authManager)
                    .badge(unreadCount)
            }
            .tabItem {
                Label("消息", systemImage: "message")
            }
            .tag(2)
            
            // 我的
            NavigationStack {
                ProfileView()
                    .environmentObject(authManager)
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
            .tag(3)
        }
        .task {
            await loadUnreadCount()
        }
    }
    
    private func loadUnreadCount() async {
        do {
            let notice = try await NoticeService.shared.unread()
            unreadCount = notice.totalUnread
        } catch {
            print("加载未读数失败: \(error)")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
}
