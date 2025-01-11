//
//  CoinBuy+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/1/6.
//

import SwiftUI

// 定义积分产品数据结构
struct CoinProduct {
  let id: String
  let coins: Int
  let price: Double
  let isPopular: Bool
}

struct CoinBuy_Sheet: View {
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var notice: NoticeManager
  @State private var selectedProduct: CoinProduct?

  var onConfirm: ((_ product: CoinProduct) -> Void)?
  var onCancel: (() -> Void)?

  // 模拟积分产品数据
  private let products: [CoinProduct] = [
    CoinProduct(id: "coin_100", coins: 10, price: 1, isPopular: false),
    CoinProduct(id: "coin_200", coins: 50, price: 5, isPopular: false),
    CoinProduct(id: "coin_500", coins: 100, price: 10, isPopular: false),
    CoinProduct(id: "coin_1000", coins: 580, price: 50, isPopular: true),
    CoinProduct(id: "coin_2000", coins: 1000, price: 100, isPopular: false),
    CoinProduct(id: "coin_5000", coins: 5000, price: 500, isPopular: false),
  ]

  init(onConfirm: ((_ product: CoinProduct) -> Void)? = nil, onCancel: (() -> Void)? = nil) {
    self.onConfirm = onConfirm
    self.onCancel = onCancel
    let popularProduct = products.first { $0.isPopular }
    _selectedProduct = State(initialValue: popularProduct)
  }

  var body: some View {
    VStack(spacing: 24) {
      // 标题栏
      HStack {
        Text("购买积分")
          .font(.headline)
          .foregroundColor(.primary)
        Spacer()
        Button(action: {
          sheet.close()
        }) {
          Image(systemName: "xmark")
            .foregroundColor(.gray)
            .font(.system(size: 18))
        }
      }
      .padding(.bottom, 8)

      // 积分产品网格
      LazyVGrid(
        columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 8
      ) {
        ForEach(products, id: \.id) { product in
          ProductCoinCard(
            product: product,
            isSelected: selectedProduct?.id == product.id
          )
          .onTapGesture {
            selectedProduct = product
          }
        }
      }

      Spacer()

      // 确认按钮
      Button(action: {
        if let product = selectedProduct {
          onConfirm?(product)
          sheet.close()
        } else {
          notice.open(open: .toast("请选择充值金额"))
        }
      }) {
        Text(selectedProduct.map { "确认支付 ¥\(String(format: "%.2f", $0.price))" } ?? "确认充值")
          .primaryButton()
          .frame(height: 44)
      }
      .disabled(selectedProduct == nil)
    }
    .padding()
  }
}

// 积分产品卡片组件
struct ProductCoinCard: View {
  let product: CoinProduct
  let isSelected: Bool

  var body: some View {
    VStack(spacing: 4) {
      Text("\(product.coins)")
        .font(.headline)
        .bold()
        .font(.caption)

      Text("¥\(String(format: "%.2f", product.price))")
        .foregroundColor(.secondary)
        .font(.caption)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 60)
    .background(isSelected ? .theme.opacity(0.1) : Color(.systemGray6))
    .cornerRadius(8)
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(isSelected ? .theme : Color.clear, lineWidth: 2)
    )
    .overlay(
      Group {
        if product.isPopular {
          VStack {
            HStack {
              Spacer()
              Text("推荐")
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.theme)
                .cornerRadius(6)
            }
          }
          .offset(y: -25)
        }
      }
    )
  }
}

#Preview {
  CoinBuy_Sheet()
    .environmentObject(SheetManager())
    .environmentObject(NoticeManager())
}
