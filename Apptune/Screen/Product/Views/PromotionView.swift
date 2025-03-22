//
//  PromotionView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/8.
//

import SwiftUI

struct PromotionCardView: View {
  @EnvironmentObject var router: Router

  var productId: String
  var productName: String
  var productLogo: String
  var totalCount: Int
  var remainingCount: Int
  var isUsed: Bool
  var groups: [(group: String, total: Int, used: Int)]

  var body: some View {
    Button(action: {
      router.navigate(to: .promotionDetail(productId: productId))
    }) {
      VStack(spacing: 12) {
        HStack {
          ImgLoader(productLogo)
            .frame(width: 40, height: 40)
            .cornerRadius(8)

          VStack(alignment: .leading, spacing: 4) {
            Text(productName)
              .font(.subheadline)
              .foregroundColor(.primary)
          }

          Spacer()

          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
        }

        if !groups.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(groups, id: \.group) { group in
                HStack(spacing: 4) {
                  Text(group.group)
                    .font(.caption)
                    .foregroundColor(.secondary)
                  Text("\(group.total - group.used)/\(group.total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(4)
              }
            }
            .padding(.horizontal, 4)
          }
        }

        HStack {
          Spacer()
          HStack(spacing: 4) {
            Circle()
              .fill(isUsed ? Color.red : Color.green)
              .frame(width: 6, height: 6)
            Text(isUsed ? "已使用" : "未使用")
              .font(.caption)
              .foregroundColor(isUsed ? .red : .green)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Color(.systemBackground))
          .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct PromotionView: View {
  @EnvironmentObject var promotionService: PromotionService
  @EnvironmentObject var router: Router

  var body: some View {
    VStack {
      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(Array(promotionService.groupedPromotions.keys.sorted()), id: \.self) {
            productId in
            if let promotion = promotionService.promotions.first(where: {
              $0.productId == productId
            }) {
              let codes = promotionService.groupedPromotions[productId] ?? []
              let totalCount = codes.count
              let remainingCount = codes.filter { !$0.isUsed }.count
              let isUsed = codes.first?.isUsed ?? false

              let groups = Dictionary(grouping: codes) { $0.group }
              let groupStats = groups.map { group, codes in
                let used = codes.filter { $0.isUsed }.count
                return (group: group, total: codes.count, used: used)
              }.sorted { $0.group < $1.group }

              PromotionCardView(
                productId: productId,
                productName: promotion.productName,
                productLogo: promotion.productLogo,
                totalCount: totalCount,
                remainingCount: remainingCount,
                isUsed: isUsed,
                groups: groupStats
              )
            }
          }
        }
        .padding(.horizontal)

        if promotionService.isLoading {
          VStack {
            Spacer()
            LoadingComponent()
              .frame(height: 480)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
          }
        } else if promotionService.groupedPromotions.isEmpty {
          EmptyView(text: "无数据", image: "nodata", size: 68)
        }
      }
      Spacer()
      Button(action: {
        router.navigate(to: .createPromotion)
      }) {
        Text("新增促销码")
          .loadingButton(loading: promotionService.isLoading)
          .buttonStyle(.black)
          .frame(height: 44)
          .padding()
      }
    }
    .onAppear {
      Task {
        await promotionService.loadPromotions()
      }
    }
    .customNavigationBar(title: "促销码", router: router)
  }
}

#Preview {
  PromotionView()
    .environmentObject(PromotionService())
    .environmentObject(Router())
}
