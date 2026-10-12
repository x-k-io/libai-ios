import SwiftUI

struct EntryCardView: View {
    let entry: EntryResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // ========== 顶部作者信息 ==========
            HStack(alignment: .top, spacing: 10) {
                AsyncImage(url: entry.avatarURL) { phase in
                    if let img = phase.image {
                        img.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(Color(.systemGray4))
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.authorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let timeDesc = entry.timeDescription {
                        Text(timeDesc)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !entry.locationText.isEmpty {
                    Label(entry.locationText, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // ========== 根据 entityType 区分卡片内容 ==========
            contentByEntityType
            
            // ========== 底部互动栏（四等分，复刻截图） ==========
            HStack(spacing: 0) {
                interactionItem(
                    icon: entry.liked == true ? "heart.fill" : "heart",
                    value: "\(entry.likes ?? 0)",
                    active: entry.liked == true
                )
                Spacer()
                interactionItem(
                    icon: "bubble.right",
                    value: "\(entry.replies ?? 0)",
                    active: false
                )
                Spacer()
                interactionItem(
                    icon: "eye",
                    value: "\(entry.browses ?? 0)",
                    active: false
                )
                Spacer()
                interactionItem(
                    icon: entry.favorite == true ? "bookmark.fill" : "bookmark",
                    value: "\(entry.favorites ?? 0)",
                    active: entry.favorite == true
                )
            }
            .font(.caption)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.systemGray6))
    }
    
    // MARK: 【修复】按entityType渲染不同内容区块，去掉guard
    @ViewBuilder
    private var contentByEntityType: some View {
        if let base = entry.base {
            switch entry.entityType {
            case "article":
                // 文章类型卡片：标题、摘要、多图/封面
                VStack(alignment: .leading, spacing:10) {
                    if let title = base.title, !title.isEmpty {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                    }
                    
                    if let excerpt = base.excerpt, !excerpt.isEmpty {
                        Text(excerpt)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if let pictures = base.picture, !pictures.isEmpty {
                        ImageGridView(images: pictures)
                    } else if let cover = base.cover, !cover.isEmpty {
                        AsyncImage(url: URL(string: cover)) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Color(.systemGray5).overlay { ProgressView() }
                            }
                        }
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(10)
                    }
                }
            case "moment":
                // 动态/说说类型（预留，可后续扩展）
                VStack(alignment: .leading, spacing:10) {
                    if let excerpt = base.excerpt, !excerpt.isEmpty {
                        Text(excerpt)
                            .font(.subheadline)
                            .lineLimit(nil)
                    }
                    if let pictures = base.picture, !pictures.isEmpty {
                        ImageGridView(images: pictures)
                    }
                }
            default:
                // 默认兜底视图
                VStack(alignment: .leading, spacing:10) {
                    if let excerpt = base.excerpt, !excerpt.isEmpty {
                        Text(excerpt)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    if let cover = base.cover, !cover.isEmpty {
                        AsyncImage(url: URL(string: cover)) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fill)
                            }
                        }
                        .frame(height:160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(8)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    // 互动item
    private func interactionItem(icon: String, value: String, active: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(value)
        }
        .foregroundColor(active ? .red : .secondary)
        .if(active && icon.contains("bookmark")) { view in
            view.foregroundColor(.blue)
        }
    }
}

// MARK: 图片网格，完全保留你的代码
struct ImageGridView: View {
    let images: [String]
    
    var body: some View {
        let columns = imageColumns
        let displayImages = Array(images.prefix(9))
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(displayImages.enumerated()), id: \.offset) { index, urlString in
                AsyncImage(url: URL(string: urlString)) { phase in
                    if let img = phase.image {
                        img.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(Color(.systemGray4))
                    }
                }
                .frame(height: imageHeight)
                .clipped()
                .cornerRadius(6)
                
                if index == 8 && images.count > 9 {
                    Color.black.opacity(0.5)
                        .overlay {
                            Text("+\(images.count - 9)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .cornerRadius(6)
                }
            }
        }
        .cornerRadius(8)
    }
    
    private var imageColumns: [GridItem] {
        let count = min(images.count, 9)
        if count == 1 {
            return [GridItem(.flexible())]
        } else if count <= 4 {
            return [GridItem(.flexible()), GridItem(.flexible())]
        } else {
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        }
    }
    
    private var imageHeight: CGFloat {
        let count = min(images.count, 9)
        if count == 1 {
            return 240
        } else if count <= 4 {
            return 140
        } else {
            return 100
        }
    }
}

// 条件修饰扩展
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing:12) {
            // article类型预览
            EntryCardView(entry: EntryResponse(
                id: 1,
                accountId: 1,
                type: "article",
                authorType: "ugc",
                entityType: "article",
                entityId: 1,
                channelId: nil,
                circleId: nil,
                placeId: nil,
                longitude: nil,
                latitude: nil,
                country: nil,
                province: nil,
                city: "武汉",
                district: nil,
                place: "东湖",
                likes: 76,
                replies: 9,
                browses: 720,
                favorites:14,
                plays: nil,
                compositeOrders: nil,
                hotOrders: nil,
                newOrders: nil,
                status: "published",
                releasedAt: "2024-01-01",
                nickname: "匿名用户",
                avatar: nil,
                liked: false,
                favorite: false,
                timeDescription: "1个月前",
                base: EntryBase(
                    title: "文章标题",
                    subtitle: nil,
                    cover: nil,
                    picture: nil,
                    excerpt: "文章摘要内容",
                    detail: nil,
                    video: nil
                )
            ))
            .padding(.horizontal)
            
            // moment动态类型预览
            EntryCardView(entry: EntryResponse(
                id: 2,
                accountId: 2,
                type: "moment",
                authorType: "ugc",
                entityType: "moment",
                entityId: 2,
                channelId: nil,
                circleId: nil,
                placeId: nil,
                longitude: nil,
                latitude: nil,
                country: nil,
                province: nil,
                city: "北京",
                district: nil,
                place: "中关村",
                likes: 204,
                replies: 41,
                browses: 2100,
                favorites:67,
                plays: nil,
                compositeOrders: nil,
                hotOrders: nil,
                newOrders: nil,
                status: "published",
                releasedAt: "2024-01-01",
                nickname: "匿名用户",
                avatar: nil,
                liked: false,
                favorite: false,
                timeDescription: "1个月前",
                base: EntryBase(
                    title: nil,
                    subtitle: nil,
                    cover: nil,
                    picture: nil,
                    excerpt: "动态内容，不需要标题，直接展示正文",
                    detail: nil,
                    video: nil
                )
            ))
            .padding(.horizontal)
        }
    }
    .background(Color(.systemGray6))
}
