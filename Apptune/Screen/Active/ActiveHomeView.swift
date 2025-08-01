//
//  ActiveHomeView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/9.
//

import Foundation
import ScalingHeaderScrollView
import SwiftUI

enum Catalog: String, CaseIterable, Codable {
  case all
  case effect
  case tool
  case life
  case video
  case weather
  case picture
  case money
  case game
  case news
  case other

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Catalog(rawValue: rawValue) ?? .effect  // 如果找不到匹配值，默认为 effect
  }

  var label: String {
    switch self {
    case .all: return "全部"
    case .effect: return "效率"
    case .tool: return "工具"
    case .life: return "生活"
    case .video: return "影视"
    case .weather: return "天气"
    case .picture: return "图形与设计"
    case .money: return "财务"
    case .game: return "游戏"
    case .news: return "新闻"
    case .other: return "其他"
    }
  }
}

let gradientSurface = LinearGradient(
  colors: [.white.opacity(0.01), .clear],
  startPoint: .topLeading,
  endPoint: .bottomTrailing
)

struct TopActiveCardView: View {
  var active: ActiveInfo
  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 8) {
        if let tag = active.recommendTag {
          Text(tag)
            .foregroundColor(.theme.opacity(0.68))
            .font(.system(size: 14))
            .fontWeight(.bold)
        }

        HStack {
          Text(active.title)
            .font(.system(size: 20))
            .fontWeight(.bold)
          Spacer()
        }
        if let desc = active.recommendDesc {
          Text(desc)
            .foregroundColor(.gray)
        }
      }
      .padding(.top, 16)
      ImgLoader(active.cover, contentMode: .fill)
        .frame(maxHeight: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.vertical)
        .padding(.horizontal, 12)
        .background(.white)
        .cornerRadius(12)
    }
    .frame(maxWidth: .infinity)
    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
  }
}

struct ActiveHomeView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @State var current: Catalog = .all
  @EnvironmentObject var activeService: ActiveService

  @State private var isLoading: Bool = false

  var GroupView: some View {
    VStack(alignment: .leading) {
      ScrollView(.horizontal, showsIndicators: false) {
        ScrollViewReader { value in
          HStack {
            ForEach(Catalog.allCases, id: \.rawValue) { c in
              ViewThatFits(content: {
                Text(c.label)
                  .font(.system(size: 20))
                  .fontWeight(.bold)
                  .conditionalModifier(
                    c == current,
                    modifier: { view in
                      view.underLine(.theme)
                    }
                  )
                  .onTapGesture {
                    Tap.shared.play(.light)
                    current = c
                    withAnimation(.easeInOut(duration: 1)) {
                      value.scrollTo(c.rawValue, anchor: .center)
                    }
                  }
              })
              .padding(.trailing, 8)
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .frame(height: 32)
    }

  }

  @State private var offset: CGFloat = -24
  @State private var currentIndex: Int = 0

  let cardWidth = UIScreen.main.bounds.width - 48
  let spacing: CGFloat = 12

  var body: some View {
    ScrollView {
      if activeService.allPage.loading && activeService.needsInitialLoad() {
        VStack {
          Spacer()
          LoadingComponent()
          Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
      } else {
        mainContent
      }
    }
    .animation(.easeInOut(duration: 0.3), value: activeService.allPage.loading)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#f4f4f4"))
    .onAppear {
      Task {
        await activeService.loadAllActives(refresh: true)
        await activeService.loadTopActives(refresh: true)
      }
    }
    .customNavigationBar(
      title: "活动中心", router: router,
      trailingItem: {
        AnyView(
          SFSymbol.search
            .font(.system(size: 18))
            .onTapGesture {
              Tap.shared.play(.light)
              router.navigate(to: .searchActive)
            }
        )
      })
  }

  private var mainContent: some View {
    VStack {
      if activeService.topActives.count > 0 {
        GeometryReader { geometry in
          HStack(spacing: spacing) {
            ForEach(activeService.topActives, id: \.id) { active in
              TopActiveCardView(active: active)
                .frame(width: cardWidth)
            }
          }
          .frame(width: geometry.size.width, alignment: .leading)
          .offset(x: offset)
          .gesture(
            DragGesture(minimumDistance: 5)
              .onChanged { value in
                let translation = value.translation.width
                let baseOffset = -CGFloat(currentIndex) * (cardWidth + spacing)
                let dampingFactor: CGFloat = 0.8
                let dampedTranslation = translation * dampingFactor
                offset = baseOffset + dampedTranslation + 24
              }
              .onEnded { value in
                let velocity = value.predictedEndTranslation.width - value.translation.width
                let threshold = cardWidth / 4

                if abs(velocity) > 100 || abs(value.translation.width) > threshold {
                  if value.translation.width > 0 {
                    currentIndex = max(currentIndex - 1, 0)
                  } else {
                    currentIndex = min(currentIndex + 1, activeService.topActives.count - 1)
                  }
                }

                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                  offset = -CGFloat(currentIndex) * (cardWidth + spacing) + 24
                }
              }
              .simultaneously(
                with:
                  TapGesture()
                  .onEnded {
                    if let active = activeService.topActives[safe: currentIndex] {
                      withAnimation {
                        router.navigate(to: .activeDetail(active: active))
                      }
                    }
                  }
              )
          )
          .onAppear {
            offset = -CGFloat(currentIndex) * (cardWidth + spacing) + 24
          }
        }
        .frame(height: 240)
      }

      if activeService.allActives.count > 0 {
        VStack {
          HStack {
            Text("最新")
              .font(.system(size: 22))
              .fontWeight(.bold)
            Spacer()
          }
          .padding(.horizontal)
          ForEach(activeService.allActives, id: \.id) { active in
            ActiveCard(
              title: active.title,
              description: active.description,
              startAt: active.startAt,
              endAt: active.endAt,
              joinCount: active.joinCount ?? 0,
              status: active.status,
              cover: active.cover,
              productName: active.productName,
              productLogo: active.productLogo
            )
            .padding(.bottom, 16)
            .contentShape(Rectangle())
            .onTapGesture {
              withAnimation {
                router.navigate(to: .activeDetail(active: active))
              }
            }
          }
          .padding(.horizontal)
        }
      } else {
        EmptyView(text: "还没有人发布活动", image: "empty")
      }
    }
  }
}

extension Collection {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

#Preview {
  ActiveHomeView()
    .environmentObject(ActiveService())
    .environmentObject(Router())
}
