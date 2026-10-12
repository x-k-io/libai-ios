import SwiftUI

struct MessageView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var chats: [ChatResponse] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            if chats.isEmpty && !isLoading {
                emptyView
            } else {
                List {
                    ForEach(chats) { chat in
                        ChatRowView(chat: chat)
                            .onTapGesture {
                                // TODO: 跳转到聊天详情页
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await loadChats()
                }
            }
        }
        .navigationTitle("消息")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: 跳转到通知列表
                }) {
                    Image(systemName: "bell")
                }
            }
        }
        .task {
            if chats.isEmpty {
                await loadChats()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无消息")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button("重新加载") {
                Task {
                    await loadChats()
                }
            }
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadChats() async {
        isLoading = true
        
        do {
            chats = try await ChatService.shared.getChatList()
        } catch {
            print("加载聊天列表失败: \(error)")
        }
        
        isLoading = false
    }
}

struct ChatRowView: View {
    let chat: ChatResponse
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            AsyncImage(url: chat.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(chat.lastTimeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(chat.lastContent ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // 未读数
            if let unread = chat.unreadCount, unread > 0 {
                Text("\(unread)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MessageView()
            .environmentObject(AuthManager.shared)
    }
}
