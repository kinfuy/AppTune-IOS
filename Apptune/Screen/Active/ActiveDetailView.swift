//
//  ActiveDetailView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/10.
//

import SwiftUI

struct ActiveDetailView: View {
  var active: ActiveInfo
  @EnvironmentObject var activeService: ActiveService
  @EnvironmentObject var router: Router
  // 头部视图
  private var HeaderView: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 活动封面图 - 使用 images 数组中的图片
      if !active.images.isEmpty {
        TabView {
          ForEach(active.images, id: \.self) { imageUrl in
            ImgLoader(imageUrl)
              .frame(height: 400)
              .clipped()
          }
        }
        .frame(height: 400)
        .tabViewStyle(PageTabViewStyle())
      } else {
        // 如果没有 images，则使用 cover 作为备选
        ImgLoader(active.cover)
          .frame(height: 400)
          .clipped()
      }

      // 活动标题和基本信息
      VStack(alignment: .leading, spacing: 8) {
        Text(active.title)
          .font(.title2)
          .fontWeight(.bold)

        HStack {
          ImgLoader(active.productLogo)
            .frame(width: 20, height: 20)

          Text(active.productName)
            .font(.subheadline)
            .foregroundColor(.gray)
        }

        // 活动时间
        HStack {
          Image(systemName: "clock")
          Text("\(active.startAt.formatted())")
            .font(.subheadline)
            .foregroundColor(.gray)
          if let endAt = active.endAt {
            Text("-\(endAt.formatted())")
              .font(.subheadline)
              .foregroundColor(.gray)
          }
        }

        // 参与人数
        HStack {
          Image(systemName: "person.2")
          Text("\(active.joinCount ?? 0)人参与")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      }
      .padding()
    }
  }

  // 活动详情
  private var ContentView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("活动详情")
        .font(.headline)
        .fontWeight(.bold)

      Text(active.description)
        .font(.body)
        .foregroundColor(.secondary)
    }
    .padding()
  }

  // 底部操作栏
  private var BottomBar: some View {
    VStack {
      Button(action: {
        // 处理参与活动的逻辑
        Task {
          await joinActive()
        }
      }) {
        Text("立即参与")
          .primaryButton()
          .frame(height: 48)
      }
    }
    .padding()
    .background(Color.white)
  }

  var body: some View {
    ZStack {
      ScrollView {
        VStack {
          HeaderView
          ContentView
          Spacer(minLength: 80)  // 为底部栏留出空间
        }
      }

      VStack {
        Spacer()
        BottomBar
      }
    }
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationTitle(active.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
        leading: Button(action: { router.back() }) {
            Label("返回", systemImage: "chevron.left")
                .foregroundStyle(Color(hex: "#333333"))
        }
    )
  }

  // 参与活动
  private func joinActive() async {
  }
}

#Preview {
  ActiveDetailView(
    active: ActiveInfo(
      id: "preview-1",
      title: "新人专享活动",
      description:
        "欢迎加入我们!参与活动即可获得积分奖励。活动期间完成任务最高可得1000积分,可用于兑换商城礼品。\n\n活动规则:\n1. 首次登录奖励100积分\n2. 每日签到奖励10积分\n3. 邀请好友奖励50积分/人\n4. 完成新手任务奖励200积分",
      cover: "https://picsum.photos/800/400",
      startAt: Date(),
      endAt: Date().addingTimeInterval(7 * 24 * 60 * 60),
      limit: 1000,
      rewardType: .points,
      joinCount: 128,
      likeCount: 56,
      status: 1,
      createTime: Date(),
      productId: "product-1",
      productName: "示例产品",
      productLogo: "https://picsum.photos/100/100",
      images: ["https://picsum.photos/400/600","https://picsum.photos/400/600","https://picsum.photos/400/600"],
      tags: [
        TagEntity(name: "新人专享", color: .theme),
        TagEntity(name: "限时活动", color: .orange),
      ],
      link: nil,
      reward: "1000积分"
    )
  )
  .environmentObject(ActiveService())
}
