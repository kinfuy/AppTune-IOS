import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var productService: ProductService
    @EnvironmentObject var activeService: ActiveService
    @EnvironmentObject var userService: UserService

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // 待审核活动列表
                if !activeService.pendingActiveReviews.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("待审核活动")
                                .font(.headline)
                            Text("\(activeService.pendingActiveReviews.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }

                        ForEach(activeService.pendingActiveReviews) { activity in
                            ActivityReviewCard(activity: activity) { status in
                                await activeService.review(id: activity.id, status: status)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                // 待审核产品列表
                if !productService.pendingProductReviews.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("待审核产品")
                                .font(.headline)
                            Text("\(productService.pendingProductReviews.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }

                        ForEach(productService.pendingProductReviews) { product in
                            ProductReviewCard(product: product) { status in
                                await productService.review(id: product.id, status: status)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 空状态展示
                if productService.pendingProductReviews.isEmpty
                    && activeService.pendingActiveReviews.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("暂无待审核内容")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
            }
            .padding(.horizontal)
        }
    }
}

// 审核卡片组件
struct ProductReviewCard: View {
    let product: ProductInfo
    let onReview: (_ status: Int) async -> Void

    @State private var showContextMenu = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和图标
            HStack(spacing: 12) {
                ImgLoader(product.icon)
                .frame(width: 40, height: 40)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                    Text(product.developer ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // 描述
            if !product.description.isEmpty {
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            // 分类和时间
            HStack {
                Label(product.category.label, systemImage: "tag")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text(product.createTime.formatted(.dateTime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // 修改操作按钮部分
            HStack(spacing: 12) {
                Menu {
                    Button {
                        Task { await onReview(2) }
                    } label: {
                        Label("通过审核", systemImage: "checkmark.circle")
                    }

                    Button(role: .destructive) {
                        Task { await onReview(3) }
                    } label: {
                        Label("拒绝", systemImage: "xmark.circle")
                    }
                } label: {
                    Label("审核操作", systemImage: "ellipsis.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer()

                if let link = product.link {
                    Link(destination: URL(string: link) ?? URL(string: "https://www.apple.com")!) {
                        Image(systemName: "link.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ActivityReviewCard: View {
    let activity: ActiveInfo
    let onReview: (_ status: Int) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 封面图
            ImgLoader(activity.cover)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
                .clipped()

            // 标题和状态
            HStack {
                Text(activity.title)
                    .font(.headline)

                Spacer()
            }

            // 描述
            if !activity.description.isEmpty {
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }

            Divider()

            // 修改操作按钮部分
            HStack(spacing: 12) {
                Menu {
                    Button {
                        Task { await onReview(2) }
                    } label: {
                        Label("通过审核", systemImage: "checkmark.circle")
                    }

                    Button(role: .destructive) {
                        Task { await onReview(3) }
                    } label: {
                        Label("拒绝", systemImage: "xmark.circle")
                    }
                } label: {
                    Label("审核操作", systemImage: "ellipsis.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview("审核视图") {
    ReviewView()
        .environmentObject(ProductService())
        .environmentObject(ActiveService())
        .background(Color.gray.opacity(0.1))
}

#Preview("产品审核卡片") {
    ProductReviewCard(
        product: ProductInfo(
            id: "1",
            name: "示例产品",
            description: "这是一个非常棒的产品描述，可能会很长很长很长很长很长",
            icon: "https://picsum.photos/200",
            link: "https://www.apple.com",
            category: .life,
            price: 99,
            createTime: Date(),
            status: 1,
            developer: "开发者工作室"
        )
    ) { _ in
        // 预览用空操作
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
