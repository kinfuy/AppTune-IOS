//
//  ProductShowView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2025/2/23.
//

import SwiftUI

struct ProductShowView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var productService: ProductService

  var latestProducts: [ProductInfo] {
    productService.allProducts
  }

  var body: some View {
    Group {
      if productService.allPage.loading {
        VStack {
          Spacer()
          LoadingComponent()
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            // 最新产品区域
            VStack(alignment: .leading, spacing: 12) {
              Text("最新产品")
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal)

              LazyVStack(spacing: 16) {
                ForEach(latestProducts) { product in
                  ProductCard(
                    title: product.name,
                    description: product.description,
                    stars: 0,
                    category: product.category,
                    logo: product.icon,
                    developer: product.developer ?? "",
                    publisher: product.publisher ?? "",
                    status: product.status ?? 1
                  )
                }
              }
              .padding(.horizontal)
            }
          }
          .padding(.top)
        }
      }
    }
    .customNavigationBar(title: "产品发布会", router: router)
    .onAppear {
      Task {
        await productService.loadAllProductList(refresh: true)
      }
    }
  }
}

// 数据模型
struct FeaturedProduct: Identifiable {
  let id = UUID()
  let name: String
  let description: String
  let category: String
  let icon: String
  let developer: String
  let status: Int  // 1: 开发中, 2: 已上线
}

#Preview {
  ProductShowView()
    .environmentObject(Router())
    .environmentObject(ProductService())
}
