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
  @EnvironmentObject var productService: ProductService
  @EnvironmentObject var userService: UserService
  @EnvironmentObject var router: Router
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var notice: NoticeManager
  @State private var showDeleteAlert = false
  @State private var hasJoined = false
  @State private var hasSubmitted = false

  private var isSelfActive: Bool {
    if !userService.isLogin {
      return false
    }
    return active.userId == userService.profile.id
  }

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
        ImgLoader(active.cover)
          .frame(height: 400)
          .clipped()
      }

      // 活动标题和基本信息
      VStack(alignment: .leading, spacing: 16) {
        Text(active.title)
          .font(.title2)
          .fontWeight(.bold)
          .lineSpacing(4)

        HStack(spacing: 12) {
          ImgLoader(active.productLogo)
            .frame(width: 38, height: 38)
            .cornerRadius(all: 8)

          Text(active.productName)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.primary)
        }

        VStack(alignment: .leading, spacing: 10) {
          HStack(spacing: 6) {
            Image(systemName: "clock")
              .font(.system(size: 14))
              .foregroundColor(.blue)
            Text("\(active.startAt.formatted(.dateTime.year().month().day()))")
              .font(.system(size: 14))
              .foregroundColor(.secondary)
            if let endAt = active.endAt {
              Text("-\(endAt.formatted(.dateTime.year().month().day()))")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
          }

          if let limit = active.limit {
            HStack(spacing: 6) {
              Image(systemName: "person")
                .font(.system(size: 14))
                .foregroundColor(.blue)
              Text("\(limit) 人数限制")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
          }
        }
        .padding(.top, 4)
      }
      .padding(.horizontal)
    }
  }

  // 奖励板块
  private var RewardView: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("活动奖励")
          .font(.headline)
          .fontWeight(.bold)
        Spacer()
      }
      RewardContentView(
        rewardType: active.rewardType, reward: active.reward, rewardPoints: active.rewardPoints)
    }
    .padding()
  }

  // 活动详情
  private var ContentView: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("活动详情")
          .font(.headline)
          .fontWeight(.bold)
        Spacer()
      }

      HStack {
        Text(active.description)
          .font(.body)
          .foregroundColor(.secondary)
        Spacer()
      }
    }
    .padding()
  }

  // 活动创建者的底部操作栏
  private var CreatorBar: some View {
    HStack(spacing: 12) {
      // 主要操作按钮 - 管理报名用户
      Button(action: {
        router.navigate(to: .registration(active: active))
      }) {
        HStack {
          Image(systemName: "person.2")
          Text("报名管理")
        }
        .primaryButton()
        .frame(height: 48)
      }
      .frame(maxWidth: .infinity)

      // 次要操作按钮组
      HStack(spacing: 8) {
        // 分享活动
        Button(action: {
          router.navigate(to: .activeShare(active: active))
        }) {
          VStack {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: 20))
            Text("分享")
              .font(.caption)
          }
          .foregroundColor(.black)
          .frame(width: 60, height: 48)
        }
      }
    }
    .padding()
    .background(Color.white)
  }

  // 底部操作栏
  private var JoinBar: some View {
    VStack {
      Button(action: {
        if !hasJoined {
          Task {
            await joinActive()
          }
        } else {
          // 不管是否提交过,都可以进入审核页面
          router.navigate(to: .submitActiveReview(active: active, mode: .edit, userId: nil))
        }
      }) {
        Text(buttonText)
          .primaryButton()
          .frame(height: 48)
      }
    }
    .padding()
    .background(Color.white)
  }

  private var buttonText: String {
    if !hasJoined {
      return "立即报名"
    } else if hasSubmitted {
      return "查看审核"
    } else {
      return "提交审核"
    }
  }

  var body: some View {
    ZStack {
      ScrollView {
        VStack {
          HeaderView
          RewardView
          ContentView
          Spacer(minLength: 80)  // 为底部栏留出空间
        }
      }

      VStack {
        Spacer()
        if isSelfActive {
          CreatorBar
        } else {
          JoinBar
        }
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
      },
      // 更多操作
      trailing: Group {
        if isSelfActive {
          Menu {
            // 活动创建者可以编辑和结束活动
            Button(action: {
              Task {
                await productService.load()
              }
              router.navigate(to: .publishActivity(active: active))
            }) {
              Label("编辑", systemImage: "pencil")
            }

            Divider()

            // 管理员和活动创建者都可以删除活动
            Button(
              role: .destructive,
              action: {
                notice.open(
                  open: .confirm(
                    Confirm(
                      title: "确定删除此活动吗",
                      desc: "删除后数据将无法恢复",
                      onSuccess: {
                        Task {
                          await deleteActive()
                        }
                      }
                    )
                  )
                )
              }
            ) {
              Label("删除", systemImage: "trash")
                .foregroundColor(.red)
            }

          } label: {
            Image(systemName: "ellipsis")
              .foregroundStyle(Color(hex: "#333333"))
              .frame(width: 24, height: 24)
          }
        }
      }
    )
    .onAppear {
      Task {
        // 只有在不是自己的活动时才检查报名状态
        if userService.isLogin && !isSelfActive {
          let status = await activeService.checkActiveStatus(id: active.id)
          hasJoined = status.hasJoined
          hasSubmitted = status.hasSubmitted
        }
      }
    }
  }

  // 参与活动
  private func joinActive() async {
    if !userService.isLogin {
      router.navigate(to: .login)
      return
    }

    await activeService.joinActive(
      id: active.id,
      success: {
        notice.open(open: .joinSuccess(JOIN_SUCCESS_NOTICE_ID))
        hasJoined = true
      }
    )
  }

  // 添加删除活动的方法
  private func deleteActive() async {
    await activeService.deleteActive(
      id: active.id,
      success: {
        notice.open(open: .toast("删除成功"))
        Task {
          await activeService.loadSelfActives(refresh: true)
        }
        router.back()
      })
  }
}

#Preview {
  NavigationStack {
    ActiveDetailView(
      active: ActiveInfo(
        id: "preview-1",
        title: "新人专享活动",
        description:
          "欢迎加入我们!参与活动即可获得积分奖励。活动期间完成任务最高可得1000积分,可用于兑换商城礼品。\n\n活动规则:\n1. 首次登录奖励100积分\n2. 每日签到奖励10积分\n3. 邀请好友奖励50积分/人\n4. 完成新手任务奖励200积分",
        cover: "https://picsum.photos/800/400",
        startAt: Date(),
        endAt: Date().addingTimeInterval(7 * 24 * 60 * 60),
        isAutoEnd: true,
        limit: 1000,
        rewardType: .points,
        joinCount: 128,
        likeCount: 56,
        status: 1,
        createTime: Date(),
        productId: "product-1",
        productName: "示例产品",
        productLogo: "https://picsum.photos/100/100",
        images: [
          "https://picsum.photos/400/600", "https://picsum.photos/400/600",
          "https://picsum.photos/400/600",
        ],
        tags: [
          TagEntity(name: "新人专享", color: .theme),
          TagEntity(name: "限时活动", color: .orange),
        ],
        link: nil,
        reward: "活动期间完成任务最高可得1000积分,可用于兑换商城礼品",
        auditType: .manual,
        isAutoReward: false,
        rewardPoints: 1000,
        rewardPromoCodes: nil,
        userId: "1",
        isTop: false,
        recommendTag: nil,
        recommendDesc: nil,
        pubMode: .pro
      )
    )
    .environmentObject(ActiveService())
    .environmentObject(UserService())
    .environmentObject(SheetManager())
    .environmentObject(NoticeManager())
  }
}
