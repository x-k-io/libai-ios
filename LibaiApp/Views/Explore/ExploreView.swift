import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var topicCategories: [TopicCategoryResponse] = []
    @State private var isLoading = false
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("搜索话题", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // 话题分类
                if topicCategories.isEmpty && !isLoading {
                    emptyView
                } else {
                    ForEach(topicCategories) { category in
                        TopicCategorySection(category: category)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("发现")
        .task {
            await loadTopics()
        }
        .refreshable {
            await loadTopics()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无话题")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button("重新加载") {
                Task {
                    await loadTopics()
                }
            }
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    private func loadTopics() async {
        isLoading = true
        
        do {
            topicCategories = try await TopicService.shared.getTopics()
        } catch {
            print("加载话题失败: \(error)")
        }
        
        isLoading = false
    }
}

struct TopicCategorySection: View {
    let category: TopicCategoryResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 分类标题
            HStack {
                Text(category.name ?? "未分类")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("查看全部") {
                    // TODO: 跳转到分类详情页
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // 话题列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let topics = category.topics {
                        ForEach(topics) { topic in
                            TopicCardView(topic: topic)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct TopicCardView: View {
    let topic: TopicResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图标
            AsyncImage(url: topic.iconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
            }
            .frame(width: 120, height: 80)
            .clipped()
            .cornerRadius(8)
            
            // 名称
            Text(topic.name ?? "")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            // 描述
            if let description = topic.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 统计
            HStack(spacing: 10) {
                if let reads = topic.reads {
                    Label("\(reads)", systemImage: "eye")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if let mentions = topic.mentions {
                    Label("\(mentions)", systemImage: "bubble.left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 120)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ExploreView()
            .environmentObject(AuthManager.shared)
    }
}
