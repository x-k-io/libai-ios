import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var entries: [EntryResponse] = []
    @State private var isLoading = false
    @State private var selectedOrderType: EntryOrderType = .recommend
    @State private var pageNum = 1
    @State private var hasMore = true
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部选择器
            Picker("排序", selection: $selectedOrderType) {
                Text("推荐").tag(EntryOrderType.recommend)
                Text("最新").tag(EntryOrderType.latest)
                Text("热门").tag(EntryOrderType.hot)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedOrderType) { _ in
                Task {
                    pageNum = 1
                    hasMore = true
                    await loadEntries()
                }
            }
            
            // 内容列表
            if entries.isEmpty && !isLoading {
                emptyView
            } else {
                List {
                    ForEach(entries) { entry in
                        EntryCardView(entry: entry)
                            .onTapGesture {
                                // TODO: 跳转到详情页
                            }
                    }
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if hasMore {
                        Button("加载更多") {
                            Task {
                                pageNum += 1
                                await loadMoreEntries()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    pageNum = 1
                    hasMore = true
                    await loadEntries()
                }
            }
        }
        .navigationTitle("首页")
        .task {
            if entries.isEmpty {
                await loadEntries()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无内容")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button("重新加载") {
                Task {
                    await loadEntries()
                }
            }
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadEntries() async {
        isLoading = true
        
        do {
            let result = try await EntryService.shared.explore(
                orderType: selectedOrderType.rawValue,
                pageNum: pageNum
            )
            entries = result.records ?? []
            hasMore = (result.records?.count ?? 0) >= 10
        } catch {
            print("加载内容失败: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadMoreEntries() async {
        isLoading = true
        
        do {
            let result = try await EntryService.shared.explore(
                orderType: selectedOrderType.rawValue,
                pageNum: pageNum
            )
            if let newEntries = result.records {
                entries.append(contentsOf: newEntries)
            }
            hasMore = (result.records?.count ?? 0) >= 10
        } catch {
            print("加载更多失败: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthManager.shared)
    }
}
