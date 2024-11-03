//
//  ActiveHomeView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/9.
//

import ScalingHeaderScrollView
import SwiftUI

enum Catalog: String, CaseIterable {
  case all = "全部"
  case effect = "效率"
  case tool = "工具"
  case life = "生活"
  case video = "影视"
  case weather = "天气"
  case picture = "图形与设计"
  case money = "财务"
  case game = "游戏"
  case news = "新闻"
}

let gradientSurface = LinearGradient(
  colors: [.white.opacity(0.1), .clear],
  startPoint: .topLeading,
  endPoint: .bottomTrailing
)

struct ActiveCardView: View {
  var body: some View {
    VStack {
      HStack(alignment: .top) {
        Image("dog")
          .resizable()
          .frame(width: 100, height: 100)
          .clipShape(.rect(cornerRadius: 8))
        VStack(alignment: .leading, spacing: 8) {
          HStack(alignment: .top) {
            Text("Suka数字卡片,全新版本内测开启中")
          }
          HStack {
            Text("进行中")
              .font(.system(size: 14))
              .colorTag(.theme)
            Text("条件")
              .font(.system(size: 14))
              .colorTag(.red)
            Text("积分奖励")
              .font(.system(size: 14))
              .colorTag(.orange)
          }
          Spacer()
        }
      }
      HStack {
        Text("“遇见数字，发现有趣”，本次内测带来了全新的产品碎片卡片，期待大家的参与1")
          .font(.system(size: 14))
          .foregroundColor(.gray)
      }

      HStack {
        HStack {
          Image("logo")
            .resizable()
            .frame(width: 24, height: 24)
            .background(.theme.opacity(0.2))
            .clipShape( /*@START_MENU_TOKEN@*/Circle() /*@END_MENU_TOKEN@*/)
          Text("Suka数字卡片")
            .font(.system(size: 14))
            .foregroundColor(.theme)
        }
        Spacer()
        Text("立即参与")
          .font(.system(size: 14))
          .foregroundColor(.white)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background(.black)
          .cornerRadius(16)
      }
      .padding(.top, 4)
    }
    .padding(12)
    .background(.white)
    .cornerRadius(16)
    .frame(maxHeight: 240)
  }
}

struct TopActiveCardView: View {
  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 8) {
        Text("新人奖励")
          .foregroundColor(.theme.opacity(0.68))
          .font(.system(size: 14))
          .fontWeight(.bold)
        HStack {
          Text("七日积分好礼")
            .font(.system(size: 20))
            .fontWeight(.bold)
          Spacer()
        }
        Text("新用户专属任务")
          .foregroundColor(.gray)
      }
      .padding(.top, 16)
      HStack {
        VStack {
          HStack {
            Text("抢")
              .font(.system(size: 24))
            Text("“鲜”")
              .foregroundColor(.theme)
              .font(.system(size: 28))
              .fontWeight(.bold)
          }
          HStack {
            Spacer()
            Text("一步")
              .font(.system(size: 24))
          }
        }
        HStack {
          Spacer()
          ImgLoader("app")
            .frame(width: 120, height: 80)
        }
      }
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
                Text(c.rawValue)
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
      VStack {
        GeometryReader { geometry in
          HStack(spacing: spacing) {
            ForEach(0..<5) { _ in
              TopActiveCardView()
                .frame(width: cardWidth)
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

      VStack {
        HStack {
          Text("热门")
            .font(.system(size: 22))
            .fontWeight(.bold)
          Spacer()
        }
        .padding(.horizontal)
        ScrollView {
          Group {
            ActiveCardView()
              .onTapGesture {
                notice.openNotice(
                  open: .toast(
                    Toast(
                      msg: "敬请期待\(Date().description)"
                    )
                  )
                )
              }
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
            ActiveCardView()
              .padding(.bottom, 16)
          }
          .padding(.horizontal)
        }
      }
    }
    .pullToRefresh(isLoading: $isLoading) {
      isLoading = false
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
}
