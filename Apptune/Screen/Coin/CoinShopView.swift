import SwiftUI

struct CoinShopItem: View {
  let title: String
  let description: String
  let coin: Int
  let image: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        // 图标区域
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [Color.theme.opacity(0.15), Color.theme.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 56, height: 56)

          Image(systemName: image)
            .font(.system(size: 24))
            .foregroundColor(.theme)
        }

        Text(title)
          .font(.system(size: 16, weight: .semibold))

        Text(description)
          .font(.system(size: 12))
          .foregroundColor(.secondary)
          .lineLimit(2)

        HStack {
          HStack(spacing: 4) {
            Text("\(coin)")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(.theme)
            Text("积分")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.theme.opacity(0.1))
          )

          Spacer()

          Text("兑换")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
              LinearGradient(
                colors: [Color.theme, Color.theme.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .clipShape(Capsule())
        }
      }
      .padding(16)
      .background(Color.white)
      .cornerRadius(20)
      .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
  }
}

struct CoinShopView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var sheet: SheetManager
  @StateObject private var viewModel = CoinShopViewModel()

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // 用户积分信息卡片
        HStack {
          VStack(alignment: .leading, spacing: 6) {
            Text("当前积分")
              .font(.system(size: 14))
              .foregroundColor(.secondary)
            Text("\(viewModel.userCoin)")
              .font(.system(size: 32, weight: .bold))
              .foregroundColor(.theme)
          }
          Spacer()

          Button {
              sheet.show(.coinBuy(onConfirm: nil, onCancel: nil))
          } label: {
            HStack(spacing: 4) {
              Image(systemName: "plus.circle.fill")
              Text("充值")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
              LinearGradient(
                colors: [Color.theme, Color.theme.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .clipShape(Capsule())
          }
        }
        .padding(20)
        .background(
          ZStack {
            Color.white
            // 装饰性渐变圆
            Circle()
              .fill(
                LinearGradient(
                  colors: [Color.theme.opacity(0.1), .clear],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 100)
              .blur(radius: 20)
              .offset(x: -100, y: -20)
          }
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)

        if viewModel.items.isEmpty {
          EmptyView(text: "敬请期待", image: "nodata", size: 200)
        }

        // 商品列表
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(viewModel.items) { item in
            CoinShopItem(
              title: item.title,
              description: item.description,
              coin: item.coin,
              image: item.image,
              action: { viewModel.exchange(item) }
            )
          }
        }
        .padding(.horizontal)
      }
      .padding(.vertical)
    }
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle("积分商城")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(
        action: {
          router.back()
        },
        label: {
          Group {
            HStack {
              SFSymbol.back
            }
          }
          .foregroundStyle(Color(hex: "#333333"))
        })
    )
  }
}
