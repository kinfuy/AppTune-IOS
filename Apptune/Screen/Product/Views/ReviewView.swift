import SwiftUI

struct ReviewView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var productService: ProductService
  @EnvironmentObject var activeService: ActiveService
  @EnvironmentObject var communityService: CommunityService
  @EnvironmentObject var userService: UserService

  var isEmpty: Bool {
    productService.pendingProductReviews.isEmpty
      && activeService.pendingActiveReviews.isEmpty
      && communityService.pendingPostReviews.isEmpty
  }

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
                await activeService.loadPendingActiveReviews()
                await activeService.loadSelfActives(refresh: true)
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
                await activeService.loadPendingActiveReviews()
                await productService.loadProducts(refresh: true)
              }
            }
          }
          .padding(.horizontal)
        }
        // 待审核帖子列表
        if !communityService.pendingPostReviews.isEmpty {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("待审核帖子")
                .font(.headline)
              Text("\(communityService.pendingPostReviews.count)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }

            ForEach(communityService.pendingPostReviews) { post in
              PostReviewCard(post: post) { status in
                await communityService.auditPost(id: post.id, status: status)
                await communityService.loadPendingPostReviews()
              }
            }
          }
        }

        // 空状态展示
        if isEmpty {
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
    .customNavigationBar(title: "审核中心", router: router)
    .onAppear {
      Task {
        await productService.loadPendingProductReviews()
        await activeService.loadPendingActiveReviews()
        await communityService.loadPendingPostReviews()
      }
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
  @EnvironmentObject var sheet: SheetManager
  let activity: ActiveInfo
  let onReview: (_ status: Int) async -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 封面图
      VStack {
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
          HStack {
            Text(activity.description)
              .font(.subheadline)
              .foregroundColor(.gray)
              .lineLimit(3)
            Spacer()
          }
        }
      }
      .onTapGesture {
        sheet.show(.activityPreview(active: activity))
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

struct PostReviewCard: View {
  let post: Post
  let onReview: (_ status: Int) async -> Void
  @State private var isExpanded = false  // 控制内容展开收起

  // 定义最大显示行数
  private let collapsedLineLimit = 3

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 用户信息栏
      HStack(spacing: 12) {
        ImgLoader(post.avatar)
          .frame(width: 32, height: 32)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 2) {
          Text(post.author)
            .font(.system(size: 14, weight: .medium))
          Text("\(post.updateTime.formatted(.dateTime.year().month().day().hour().minute()))")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
        Spacer()
      }

      // 内容部分
      VStack(alignment: .leading, spacing: 4) {
        Text(post.content)
          .font(.system(size: 14))
          .lineSpacing(4)
          .lineLimit(isExpanded ? nil : collapsedLineLimit)

        // 仅当文本超过3行时显示展开/收起按钮
        if post.content.count > 50 {
          Button(action: {
            withAnimation {
              isExpanded.toggle()
            }
          }) {
            Text(isExpanded ? "收起" : "展开")
              .font(.system(size: 12))
              .foregroundColor(.theme)
          }
        }
      }

      // 图片网格
      if !post.images.isEmpty {
        ImageGridView(images: post.images)
          .frame(maxWidth: 200)
      }

      // 链接预览
      if let link = post.link {
        LinkPreview(link: link)
      }

      Divider()

      // 审核操作按钮
      HStack(spacing: 12) {
        Menu {
          Button {
            Task { await onReview(1) }
          } label: {
            Label("通过审核", systemImage: "checkmark.circle")
          }

          Button(role: .destructive) {
            Task { await onReview(2) }
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
      developer: "开发者工作室",
      publisher: ""
    )
  ) { _ in
    // 预览用空操作
  }
  .padding()
  .background(Color.gray.opacity(0.1))
}
