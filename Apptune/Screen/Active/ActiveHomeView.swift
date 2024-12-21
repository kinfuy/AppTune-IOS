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
  case all = "all"
  case effect = "effect"
  case tool = "tool"
  case life = "life"
  case video = "video"
  case weather = "weather"
  case picture = "picture"
  case money = "money"
  case game = "game"
  case news = "news"

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
    }
  }
}

let gradientSurface = LinearGradient(
  colors: [.white.opacity(0.1), .clear],
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
        ImgLoader(active.cover, contentMode: .fill )
            .frame(maxHeight: 100)
      .padding(.vertical)
      .padding(.horizontal, 12)
      .background(.white)
      .cornerRadius(12)
    }
    .frame(maxWidth: .infinity)
  }
}

struct ActiveHomeView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @State var current: Catalog = .all
  @EnvironmentObject var activeService: ActiveService

  @State private var isLoading: Bool = false
  @State var progress: CGFloat = 0

  private let minHeight = 100.0
  private let maxHeight = 120.0

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

  private var smallHeader: some View {
    HStack {
      Spacer()
      Text("活动")
        .font(.system(size: 18))
        .fontWeight(.bold)
      Spacer()
    }
    .padding(.horizontal)
  }

  private func largeHeader(progress: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 0, style: .continuous)
        .foregroundStyle(gradientSurface)
        .background(.ultraThinMaterial)
        .mask(RoundedRectangle(cornerRadius: 0, style: .circular).foregroundColor(.black))
        .overlay {
          VStack {
            Spacer()
            smallHeader
              .opacity(progress)
              .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
              .padding(.bottom, 24)
          }
        }
      VStack {
        Spacer()
        HStack {
          Text("活动")
            .font(.system(size: 28))
            .fontWeight(.bold)
          Spacer()
          SFSymbol.search
            .font(.system(size: 24))
            .onTapGesture {
              Tap.shared.play(.light)
            }
        }
      }
      .padding(.horizontal)
      .frame(height: maxHeight)
      .padding(.bottom, 24)
      .edgesIgnoringSafeArea(.all)
      .background(Color(hex: "#f4f4f4"))
      .opacity(1 - progress)
    }
  }

  @State private var offset: CGFloat = -24
  @State private var currentIndex: Int = 0

  let cardWidth = UIScreen.main.bounds.width - 48
  let spacing: CGFloat = 12

  var body: some View {
    ScalingHeaderScrollView {
      ZStack {
        largeHeader(progress: progress)
      }
    } content: {
      GroupView
        .padding(.horizontal)
      if activeService.topActives.count > 0 {
        VStack {
          GeometryReader { geometry in
            HStack(spacing: spacing) {
              ForEach(activeService.topActives, id: \.id) { active in
                TopActiveCardView(active: active)
                  .frame(width: cardWidth)
                  .onTapGesture {
                    withAnimation {
                      router.navigate(to: .activeDetail(active: active))
                    }
                  }
              }
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: offset)
            .gesture(
              DragGesture()
                .onChanged { value in
                  offset = -CGFloat(currentIndex) * (cardWidth + spacing) + value.translation.width
                }
                .onEnded { value in
                  let threshold = cardWidth / 3
                  if -value.predictedEndTranslation.width > threshold {
                    currentIndex = min(currentIndex + 1, 5 - 1)
                  } else if value.predictedEndTranslation.width > threshold {
                    currentIndex = max(currentIndex - 1, 0)
                  }
                  withAnimation {
                    offset = -CGFloat(currentIndex) * (cardWidth + spacing) + 24
                  }
                }
            )
            .onAppear {
              offset = -CGFloat(currentIndex) * (cardWidth + spacing) + 24
            }
          }
        }
        .frame(height: 240)
      }

      VStack {
        HStack {
          Text("热门")
            .font(.system(size: 22))
            .fontWeight(.bold)
          Spacer()
        }
        .padding(.horizontal)
        ScrollView {
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
        if activeService.allActives.isEmpty {
          EmptyView(text: "还没有人发布活动", image: "empty")
        }
      }
      .onAppear {
        Task {
          await activeService.loadAllActives(refresh: true)
          await activeService.loadTopActives(refresh: true)
        }
      }
    }
    .pullToRefresh(isLoading: $isLoading) {
      Task {
        await activeService.loadAllActives(refresh: true)
        await activeService.loadTopActives(refresh: true)
        isLoading = false
      }

    }
    .height(min: minHeight, max: maxHeight)
    .collapseProgress($progress)
    .hideScrollIndicators()
    .ignoresSafeArea()
    .background(Color(hex: "#f4f4f4"))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.bottom, 32)
  }
}

#Preview {
  ActiveHomeView()
    .environmentObject(ActiveService())
}
