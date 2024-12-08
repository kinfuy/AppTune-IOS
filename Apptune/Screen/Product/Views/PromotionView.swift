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

    private var totalCount: Int { codes.count }
    private var usedCount: Int { codes.filter { $0.isUsed }.count }
    private var remainingCount: Int { totalCount - usedCount }

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
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(codes, id: \.code) { code in
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
            LazyVStack(spacing: 16) {
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
            .padding()
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
