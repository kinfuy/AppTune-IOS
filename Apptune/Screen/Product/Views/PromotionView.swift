//
//  PromotionView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/8.
//

import SwiftUI

struct PromotionCardView: View {
  var productId: String
  var productName: String
  var codes: [PromotionCode]
  @State private var isExpanded = false
  @State private var expandedGroups: Set<String> = []

  private var totalCount: Int { codes.count }
  private var usedCount: Int { codes.filter { $0.isUsed }.count }
  private var remainingCount: Int { totalCount - usedCount }
  private var groupedCodes: [String: [PromotionCode]] {
    Dictionary(grouping: codes) { $0.group }
  }

  private func groupStats(_ group: String) -> (total: Int, used: Int) {
    let codesInGroup = groupedCodes[group] ?? []
    let used = codesInGroup.filter { $0.isUsed }.count
    return (codesInGroup.count, used)
  }

  var body: some View {
    VStack(spacing: 0) {
      // 卡片头部
      HStack {
        Image(systemName: "ticket.fill")
          .foregroundColor(.blue)
          .font(.footnote)
        Text("促销码")
          .font(.subheadline)
          .foregroundColor(.primary)
        Spacer()

        Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .foregroundColor(.secondary)
            .frame(width: 24, height: 24)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)

      // 产品信息部分
      HStack(spacing: 8) {
        Text(productName)
          .font(.footnote)
          .foregroundColor(.secondary)
          .lineLimit(1)

        Spacer()

        Text("已使用 \(usedCount)/\(totalCount)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 8)

      if isExpanded {
        // 展示促销码列表
        VStack(alignment: .leading, spacing: 12) {
          ForEach(Array(groupedCodes.keys.sorted()), id: \.self) { group in
            VStack(alignment: .leading, spacing: 8) {
              // 分组标题和统计
              Button(action: {
                withAnimation(.spring()) {
                  if expandedGroups.contains(group) {
                    expandedGroups.remove(group)
                  } else {
                    expandedGroups.insert(group)
                  }
                }
              }) {
                HStack {
                  Image(
                    systemName: expandedGroups.contains(group) ? "chevron.down" : "chevron.right"
                  )
                  .font(.caption)
                  .foregroundColor(.secondary)

                  Text(group)
                    .font(.caption)
                    .foregroundColor(.secondary)

                  Spacer()

                  let stats = groupStats(group)
                  Text("\(stats.used)/\(stats.total)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
              }

              if expandedGroups.contains(group) {
                // 该分组下的促销码列表
                ForEach(groupedCodes[group] ?? [], id: \.code) { code in
                  HStack {
                    Text(code.code)
                      .font(.system(.footnote, design: .monospaced))
                      .foregroundColor(code.isUsed ? .secondary : .primary)

                    Spacer()

                    if code.isUsed {
                      Text("已使用")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                  }
                  .padding(.horizontal, 12)
                  .padding(.vertical, 4)
                  .background(code.isUsed ? Color.clear : Color.blue.opacity(0.1))
                  .cornerRadius(4)
                }
              }
            }
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
          }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    )
    .padding(.horizontal, 12)
  }
}

struct PromotionView: View {
  @EnvironmentObject var promotionService: PromotionService

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 20) {
        ForEach(Array(promotionService.groupedPromotions.keys.sorted()), id: \.self) { productId in
          if let promotion = promotionService.promotions.first(where: { $0.productId == productId })
          {
            PromotionCardView(
              productId: productId,
              productName: promotion.productName,
              codes: promotionService.groupedPromotions[productId] ?? []
            )
          }
        }
      }
      .padding(.horizontal)
      if promotionService.groupedPromotions.isEmpty {
        EmptyView(text: "无数据", image: "nodata", size: 68)
      }
    }
  }
}

#Preview {
  PromotionView()
    .environmentObject(PromotionService())
}
