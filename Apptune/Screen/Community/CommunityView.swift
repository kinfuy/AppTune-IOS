//
//  CommunityView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/29.
//

import SwiftUI

struct CommunityView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var userService: UserService
  @EnvironmentObject var communityService: CommunityService

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(communityService.posts) { post in
              PostCard(post: post)
                .onAppear {
                  if post.id == communityService.posts.last?.id {
                    Task {
                      await communityService.loadMorePosts()
                    }
                  }
                }
            }

            if communityService.isLoading {
              VStack {
                Spacer()
                LoadingComponent()
                Spacer()
              }
              .frame(maxWidth: .infinity, minHeight: 400)
            } else if communityService.posts.isEmpty {
              Text("暂无内容")
                .foregroundColor(.secondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            }
          }
          .padding(.horizontal)
        }
        .refreshable {
          Task {
            await communityService.fetchPosts()
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.top)
      .background(Color(hex: "#f4f4f4"))

      VStack {
        Spacer()
        HStack {
          Spacer()
          Button {
            router.navigate(to: .createPost)
          } label: {
            Image(systemName: "plus")
              .font(.system(size: 24, weight: .semibold))
              .foregroundColor(.white)
              .frame(width: 56, height: 56)
              .background(Color.theme)
              .clipShape(Circle())
              .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
          }
          .padding(.trailing, 20)
          .padding(.bottom, 48)
        }
      }
    }
    .task {
      await communityService.fetchPosts()
    }
    .customNavigationBar(title: "社区经验", router: router)
  }
}

// 简化帖子卡片
struct PostCard: View {
  @EnvironmentObject var communityService: CommunityService
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var userService: UserService
  let post: Post
  @State private var isExpanded = false  // 添加展开状态

  // 定义最大显示行数
  private let collapsedLineLimit = 3

  var isOwner: Bool {
    post.userId == userService.profile.id
  }

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

      // 修改内容显示部分
      VStack(alignment: .leading, spacing: 4) {
        Text(post.content)
          .font(.system(size: 14))
          .lineSpacing(4)
          .lineLimit(isExpanded ? nil : collapsedLineLimit)

        // 仅当文本超过3行时显示展开/收起按钮
        if post.content.count > 50 {  // 这是一个简单的判断，你可以根据需要调整
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

      // 图片
      ImageGridView(images: post.images)
        .frame(maxWidth: 200)

      // 链接预览卡片
      if let link = post.link {
        LinkPreview(link: link)
      }

      // 修改点赞和无用按钮部分
      HStack(spacing: 16) {
        Spacer()

        // 社交按钮组
        HStack(spacing: 24) {
          SocialButton(
            title: "有用",
            icon: "hand.thumbsup",
            count: post.helpful,
            isSelected: post.isHelpful == 2,
            action: {
              if post.isHelpful == 2 {
                return
              }
              Task {
                await communityService.likePost(id: post.id)
              }
            }
          )

          SocialButton(
            title: "无用",
            icon: "hand.thumbsdown",
            count: post.notHelpful,
            isSelected: post.isHelpful == 1,
            action: {
              if post.isHelpful == 1 {
                return
              }
              Task {
                await communityService.unlikePost(id: post.id)
              }
            }
          )
        }

        // 添加更多菜单
        Menu {
          Button {
            notice.open(open: .toast("已经收到你的反馈，感谢你的支持"))
          } label: {
            Label("举报", systemImage: "exclamationmark.triangle")
          }

          if isOwner {
            Divider()

            Button(role: .destructive) {
              notice.open(
                open: .confirm(
                  title: "确定删除该经验吗",
                  desc: "删除后不可恢复，确认继续吗",
                  onSuccess: {
                    Task {
                      await communityService.deletePost(post)
                    }
                  }))
            } label: {
              Label("删除", systemImage: "trash")
            }
          }
        } label: {
          Image(systemName: "ellipsis")
            .foregroundColor(.secondary)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .padding(.horizontal, 6)
        }
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
  }
}

struct LinkPreview: View {
  @EnvironmentObject var router: Router
  let link: PostLink

  var body: some View {
    HStack(spacing: 12) {
      ImgLoader(link.thumbnail)
        .frame(width: 48, height: 48)
        .cornerRadius(8)

      VStack(alignment: .leading, spacing: 4) {
        Text(link.title)
          .font(.system(size: 14, weight: .medium))
          .lineLimit(2)

        Text(link.description)
          .font(.system(size: 12))
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
      Spacer()
    }
    .padding(8)
    .background(Color(hex: "#f4f4f4"))
    .cornerRadius(8)
    .contentShape(Rectangle())
    .onTapGesture {
      router.navigate(to: .webView(url: link.url, title: link.title))
    }
  }
}

// 图片网格视图
struct ImageGridView: View {
  let images: [String]

  var body: some View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: min(3, images.count))

    LazyVGrid(columns: columns, spacing: 4) {
      ForEach(images, id: \.self) { imageUrl in
        ImgLoader(imageUrl)
          .aspectRatio(1, contentMode: .fill)
          .clipped()
          .cornerRadius(8)
      }
    }
  }
}

// 社交按钮组件
struct SocialButton: View {
  let title: String?
  let icon: String?
  var count: Int = 0
  var isSelected: Bool = false
  var action: () -> Void = {}

  var body: some View {
    Button(action: action) {
      HStack(spacing: 4) {
        if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: 14))
        }
        if count != 0 {
          Text(count.description)
            .font(.system(size: 14))
        } else if let title = title {
          Text(title)
            .font(.system(size: 14))
        }
      }
      .foregroundColor(isSelected ? .theme : .secondary)
    }
  }
}

// 6. 预览
#Preview {
  CommunityView()
    .environmentObject(Router())
    .environmentObject(UserService())
    .environmentObject(CommunityService())
}
