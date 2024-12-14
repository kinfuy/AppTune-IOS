//
//  ActiveShareView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/12.
//

import Photos
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ActiveShareView: View {
    var active: ActiveInfo
    @State private var selectedRatio: PreviewRatio = .portrait
    @State private var isGeneratingSnapshot = false
    @EnvironmentObject var notice: NoticeManager
    @EnvironmentObject var sheet: SheetManager

    // 预览比例选项
    enum PreviewRatio: String, CaseIterable {
        case portrait = "竖屏 4:5"
        case square = "方形 1:1"
        case landscape = "横屏 16:9"

        var ratio: CGFloat {
            switch self {
            case .portrait: return 4 / 5
            case .square: return 1
            case .landscape: return 16 / 9
            }
        }
    }

    // View->UIImage
    @MainActor
    private func generateSnapshot() async -> UIImage {
        // 等待一小段时间确保图片加载
        try? await Task.sleep(nanoseconds: 500000000) // 0.5秒

        let renderer = ImageRenderer(
            content: shareView()
                .frame(width: UIScreen.main.bounds.width)
        )

        // 设置固定尺寸
        renderer.proposedSize = ProposedViewSize(
            width: UIScreen.main.bounds.width,
            height: nil // 高度自适应
        )
        renderer.scale = UIScreen.main.scale

        return renderer.uiImage ?? UIImage()
    }

    // 分享方式
    private var shareOptions: [(title: String, icon: String, action: () -> Void)] {
        [
            (
                title: "生成图片",
                icon: "photo.on.rectangle.angled",
                action: {
                    isGeneratingSnapshot = true
                    Task {
                        let shareImage = await generateSnapshot()
                        isGeneratingSnapshot = false
                        sheet.show(.imageShare(shareImage: shareImage, title: active.title, onSave: {
                            withAnimation(.spring) {
                                sheet.close()
                            }
                        }))
                    }
                }
            ),
            (
                title: "分享到小红书",
                icon: "square.and.arrow.up",
                action: { shareToXHS() }
            ),
        ]
    }

    // 新增: 生成分享内容的方法
    private func getShareContent() -> String {
        return "#\(active.productName) \n\(active.description)"
    }

    private func shareView() -> some View {
        // 预览区域
        VStack(alignment: .leading, spacing: 16) {
            PreviewCard(
                active: active,
                content: getShareContent(),
                ratio: selectedRatio.ratio
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 4)
            )
        }
        .padding(.horizontal)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 24) {
                HStack {
                    Text("预览效果")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Picker("比例", selection: $selectedRatio) {
                        ForEach(PreviewRatio.allCases, id: \.self) { ratio in
                            Text(ratio.rawValue).tag(ratio)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 14))
                }
                .padding(.horizontal)

                ScrollView {
                    shareView()
                    Spacer(minLength: 180)
                }
            }
            .padding(.top)
            .background(Color(hex: "#f4f4f4"))

            // 固定在底部的分享选项
            VStack(spacing: 16) {
                Text("分享方式")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 32) {
                    ForEach(shareOptions, id: \.title) { option in
                        ShareOptionButton(
                            title: option.title,
                            icon: option.icon,
                            action: option.action
                        )
                    }
                }
            }
            .padding()
            .background(Color.white)
        }
        .overlay {
            if isGeneratingSnapshot {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
            }
        }
    }

    // 分享功能实现
    private func shareToXHS() {
        // TODO: 实现小红书分享功能
    }
}

// 分享选项按钮
struct ShareOptionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// 预览卡片组件
struct PreviewCard: View {
    var active: ActiveInfo
    var content: String
    var ratio: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GeometryReader { geo in
                ImgLoader(active.cover)
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geo.size.width,
                        height: geo.size.width / ratio
                    )
                    .clipped()
                    .cornerRadius(12)
            }
            .aspectRatio(ratio, contentMode: .fit)

            Text(active.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding(16)
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            ActiveShareView(
                active: ActiveInfo(
                    id: "preview-1",
                    title: "新人专享活动",
                    description:
                    "欢迎加入我们!参与活动即可获得积分奖励。活动期间完成任务最高可得1000积分,可用于兑换商城礼品。\n\n活动规则:\n1. 首次登录奖励100积分\n2. 每日签到奖励10积分\n3. 邀请好友奖励50积分/人\n4. 完成新手任务奖励200积分",
                    cover: "https://picsum.photos/800/400",
                    startAt: Date(),
                    endAt: Date().addingTimeInterval(7 * 24 * 60 * 60),
                    limit: 1000,
                    rewardType: .selfManaged,
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
                        TagEntity(name: "活动", color: .orange),
                    ],
                    link: nil,
                    reward: "1000积分",
                    userId: "1"
                )
            )
        }
}
