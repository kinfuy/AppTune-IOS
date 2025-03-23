import SwiftUI

struct PromotionDetailView: View {
  @EnvironmentObject var promotionService: PromotionService
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var router: Router

  let productId: String
  @State private var selectedCodes: Set<String> = []
  @State private var showingClearAlert = false
  @State private var expandedGroups: Set<String> = []

  private var product: PromotionCode? {
    promotionService.promotions.first { $0.productId == productId }
  }

  private var codes: [PromotionCode] {
    promotionService.groupedPromotions[productId] ?? []
  }

  private var unusedCodes: [PromotionCode] {
    codes.filter { !$0.isUsed }
  }

  private var usedCodes: [PromotionCode] {
    codes.filter { $0.isUsed }
  }

  // 按分组统计
  private var groupedStats: [(group: String, total: Int, used: Int)] {
    let groups = Dictionary(grouping: codes) { $0.group }
    return groups.map { group, codes in
      let used = codes.filter { $0.isUsed }.count
      return (group: group, total: codes.count, used: used)
    }.sorted { $0.group < $1.group }
  }

  // 按分组显示促销码
  private var groupedCodes: [(group: String, codes: [PromotionCode])] {
    let groups = Dictionary(grouping: codes) { $0.group }
    return groups.map { group, codes in
      (group: group, codes: codes.sorted { $0.code < $1.code })
    }.sorted { $0.group < $1.group }
  }

  var body: some View {
    VStack(spacing: 0) {
      // 统计信息
      HStack(spacing: 16) {
        StatCard(title: "总数", value: "\(codes.count)")
        StatCard(title: "已使用", value: "\(usedCodes.count)")
        StatCard(title: "未使用", value: "\(unusedCodes.count)")
      }
      .padding(.horizontal)
      .padding(.vertical, 12)

      // 分组列表
      ScrollView {
        VStack(spacing: 16) {
          ForEach(groupedCodes, id: \.group) { group in
            GroupCard(
              group: group,
              isExpanded: expandedGroups.contains(group.group),
              onToggle: { toggleGroup(group.group) },
              selectedCodes: $selectedCodes,
              onCopy: copyCode
            )
          }
        }
        .padding(.horizontal)
      }

      if !selectedCodes.isEmpty {
        HStack {
          Text("选择 \(selectedCodes.count) 个")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Spacer()

          Button(action: {
            selectedCodes.removeAll()
          }) {
            Text("取消")
              .font(.subheadline)
              .foregroundColor(.blue)
          }
          .padding(.trailing)

          Button(action: {
            notice.open(
              open: .confirm(
                Confirm(
                  title: "确认删除促销码？",
                  onSuccess: {
                    Tap.shared.play(.light)
                    Task {
                      let deleteCodes = codes.filter { selectedCodes.contains($0.code) }
                      await promotionService.deletePromotionCode(deleteCodes)
                      notice.open(open: .toast("删除成功"))
                      selectedCodes.removeAll()
                    }
                  })))
          }) {
            Text("删除")
              .buttonStyle(.red)
              .frame(height: 44)
          }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, y: -1)
      }

    }
    .customNavigationBar(title: product?.productName ?? "促销码", router: router)
  }

  private func toggleGroup(_ group: String) {
    if expandedGroups.contains(group) {
      expandedGroups.remove(group)
    } else {
      expandedGroups.insert(group)
    }
  }

  private func copyCode(_ code: String) {
    UIPasteboard.general.string = code
    notice.open(open: .toast("已复制到剪贴板"))
  }
}

struct StatCard: View {
  let title: String
  let value: String

  var body: some View {
    VStack(spacing: 4) {
      Text(value)
        .font(.title2)
        .fontWeight(.bold)
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}

struct GroupCard: View {
  let group: (group: String, codes: [PromotionCode])
  let isExpanded: Bool
  let onToggle: () -> Void
  @Binding var selectedCodes: Set<String>
  let onCopy: (String) -> Void

  private var unusedCodes: [PromotionCode] {
    group.codes.filter { !$0.isUsed }
  }

  private var isGroupSelected: Bool {
    !group.codes.isEmpty && group.codes.allSatisfy { selectedCodes.contains($0.code) }
  }

  // 排序后的促销码列表
  private var sortedCodes: [PromotionCode] {
    group.codes.sorted { code1, code2 in
      // 首先按使用状态排序（未使用的在前）
      if code1.isUsed != code2.isUsed {
        return !code1.isUsed
      }
      // 如果使用状态相同，则按促销码排序
      return code1.code < code2.code
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // 分组头部
      HStack {
        Button(action: onToggle) {
          HStack {
            Button(action: {
              if isGroupSelected {
                group.codes.forEach { selectedCodes.remove($0.code) }
              } else {
                group.codes.forEach { selectedCodes.insert($0.code) }
              }
            }) {
              HStack(spacing: 4) {
                Image(systemName: isGroupSelected ? "checkmark.circle.fill" : "circle")
                  .foregroundColor(isGroupSelected ? .blue : .gray)
              }
            }
            VStack(alignment: .leading, spacing: 2) {
              Text(group.group)
                .font(.headline)
              Text("\(unusedCodes.count)/\(group.codes.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
              .foregroundColor(.secondary)
          }
        }

        Spacer()
      }
      .padding()
      .background(Color(.systemBackground))

      if isExpanded {
        // 促销码列表
        VStack(spacing: 0) {
          ForEach(sortedCodes, id: \.id) { code in
            PromotionCodeRow(
              code: code,
              isSelected: selectedCodes.contains(code.code),
              onSelect: { toggleSelection(code.code) },
              onCopy: { onCopy(code.code) }
            )
          }
        }
        .background(Color(.systemGray6))
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
  }

  private func toggleSelection(_ code: String) {
    if selectedCodes.contains(code) {
      selectedCodes.remove(code)
    } else {
      selectedCodes.insert(code)
    }
  }
}

struct PromotionCodeRow: View {
  let code: PromotionCode
  let isSelected: Bool
  let onSelect: () -> Void
  let onCopy: () -> Void

  var body: some View {
    HStack {
      Button(action: onSelect) {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? .blue : .gray)
      }

      Text(code.code)
        .font(.system(.footnote, design: .monospaced))
        .foregroundColor(code.isUsed ? .secondary.opacity(0.5) : .black)

      Spacer()

      if !code.isUsed {
        Button(action: onCopy) {
          Image(systemName: "doc.on.doc")
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(Color.clear)
  }
}

#Preview {
  NavigationView {
    PromotionDetailView(productId: "test")
      .environmentObject(PromotionService())
      .environmentObject(NoticeManager())
      .environmentObject(Router())
  }
}
