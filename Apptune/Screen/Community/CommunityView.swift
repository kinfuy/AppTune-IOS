//
//  CommunityView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/29.
//

import SwiftUI

struct CommunityView: View {
  // 1. 状态变量
  @State private var selectedTab = 0
  @State private var posts = []  // 假设有Post模型

  var body: some View {
    VStack(spacing: 0) {
      // 1. 固定在顶部的选项卡
      VStack(spacing: 0) {
        // 选项卡
        HStack {
          Spacer()
          TabButton(title: "最新", isSelected: selectedTab == 0) {
            withAnimation { selectedTab = 0 }
          }
          Spacer()

          TabButton(title: "关注", isSelected: selectedTab == 1) {
            withAnimation { selectedTab = 1 }
          }
          Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
          Color(.white)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
      }

      ScrollView {
        VStack(spacing: 0) {
          // 2. 圈子列表
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
              ForEach(0..<6) { index in
                CircleCard(
                  icon: index == 0 ? "sparkles" : "circle.fill",
                  title: index == 0 ? "发现更多" : "审核攻略",
                  count: index == 0 ? nil : "99+"
                )
              }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
          }

          // 3. 内容列表
          LazyVStack(spacing: 12) {
            ForEach(0..<10) { _ in
              PostCard(post: mockPost)
            }
          }
          .padding(.horizontal)
        }
      }
      .background(Color(hex: "#f4f4f4"))
    }
    .padding(.bottom, 32)
  }
}

// 自定义选项卡按钮
struct TabButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Text(title)
          .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
          .foregroundColor(isSelected ? .theme : .secondary)

        // 选中指示器
        Rectangle()
          .fill(isSelected ? .theme : Color.clear)
          .frame(height: 4)
          .frame(width: 60)
          .cornerRadius(1.5)
          // 添加动画过渡
          .animation(.spring(response: 0.3), value: isSelected)
      }
    }
  }
}

// 帖子数据模型
struct Post: Identifiable {
  let id: String = UUID().uuidString
  let title: String  // 帖子标题
  let author: String  // 作者
  let avatar: String  // 作者头像
  let time: String  // 发布时间
  let link: PostLink  // 链接
}

// 链接预览模型
struct PostLink {
  let title: String  // 链接标题
  let description: String  // 链接描述
  let thumbnail: String  // 缩略图
  let url: String  // 链接地址
}

// 简化帖子卡片
struct PostCard: View {
  let post: Post

  var body: some View {
    Button(action: {
      // TODO: 处理链接点击
    }) {
      VStack(alignment: .leading, spacing: 12) {
        // 用户信息栏
        HStack(spacing: 12) {
          AsyncImage(url: URL(string: post.avatar)) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            Color.gray.opacity(0.2)
          }
          .frame(width: 32, height: 32)
          .clipShape(Circle())

          VStack(alignment: .leading, spacing: 2) {
            Text(post.author)
              .font(.system(size: 14, weight: .medium))
            Text(post.time)
              .font(.system(size: 12))
              .foregroundColor(.secondary)
          }
          Spacer()
        }

        // 帖子标题
        Text(post.title)
          .font(.system(size: 16, weight: .medium))
          .lineSpacing(4)

        // 链接预览卡片
        HStack(spacing: 12) {
          ImgLoader(post.link.thumbnail)
            .frame(width: 48, height: 48)
            .cornerRadius(8)

          VStack(alignment: .leading, spacing: 4) {
            Text(post.link.title)
              .font(.system(size: 14, weight: .medium))
              .lineLimit(2)

            Text(post.link.description)
              .font(.system(size: 12))
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
          Spacer()
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
      }
      .padding()
      .background(Color(.systemBackground))
      .cornerRadius(16)
    }
    .buttonStyle(.plain)
  }
}

// Mock 数据
let mockPost = Post(
  title: "分享一个超赞的设计灵感!",
  author: "设计师小王",
  avatar: "https://example.com/avatar.jpg",
  time: "2分钟前",
  link: PostLink(
    title: "2024年UI设计趋势分析",
    description: "来自 UI中国",
    thumbnail: "https://example.com/thumbnail.jpg",
    url: "https://example.com/article"
  )
)

// 图片网格视图
struct ImageGridView: View {
  let images: [String]

  var body: some View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: min(3, images.count))

    LazyVGrid(columns: columns, spacing: 4) {
      ForEach(images, id: \.self) { imageUrl in
        AsyncImage(url: URL(string: imageUrl)) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          Color.gray.opacity(0.2)
        }
        .aspectRatio(1, contentMode: .fill)
        .clipped()
        .cornerRadius(8)
      }
    }
  }
}

// 链接预览卡片
struct LinkPreviewCard: View {
  let link: PostLink

  var body: some View {
    Button(action: {}) {
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
      .frame(maxWidth: .infinity)
      .padding(8)
      .background(Color(.systemGray6))
      .cornerRadius(8)
    }
  }
}

// 圈子卡片组件
struct CircleCard: View {
  let icon: String
  let title: String
  let count: String?

  var body: some View {
    VStack(spacing: 8) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(Color(.systemBackground))
          .frame(width: 64, height: 64)
          .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

        Image(systemName: icon)
          .font(.system(size: 24))
          .foregroundColor(.theme)

        if let count = count {
          Text(count)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.red)
            .clipShape(Capsule())
            .offset(x: 24, y: -24)
        }
      }

      Text(title)
        .font(.system(size: 12))
        .foregroundColor(.secondary)
    }
  }
}

// 社交按钮组件
struct SocialButton: View {
  let icon: String
  let count: String

  var body: some View {
    Button(action: {}) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 14))
        Text(count)
          .font(.system(size: 14))
      }
      .foregroundColor(.secondary)
    }
  }
}

// 6. 预览
#Preview {
  CommunityView()
}
