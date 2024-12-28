//
//  PreCodePicker+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import SwiftUI

struct ProCodeSheetConfig {
  var allowMultipleSelection: Bool  // 默认单选
  var title: String  // 标题
}

struct PreCodePickerSheet: View {
  var productId: String
  @State var selectedGroups: [String] = []
  var onSelect: ((_ groups: [String]) -> Void)?
  var onCancel: (() -> Void)?
  var config: ProCodeSheetConfig = ProCodeSheetConfig(
    allowMultipleSelection: false, title: "选择优惠码分组")

  @EnvironmentObject var promotionService: PromotionService
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var router: Router

  @State private var codes: [PromotionCode] = []

  var groupedCodes: [String: [PromotionCode]] {
    Dictionary(grouping: codes) { $0.group }
  }

  var groupCodeCounts: [(group: String, count: Int, usableCount: Int)] {
    groupedCodes.keys.sorted().map { group in
      let codes = groupedCodes[group] ?? []
      let usableCount = codes.filter { !$0.isUsed }.count
      return (group, codes.count, usableCount)
    }
  }

  var isEmpty: Bool {
    codes.isEmpty
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button {
          withAnimation {
            sheet.close()
            onCancel?()
          }
        } label: {
          Text("取消")
            .foregroundColor(.secondary)
            .font(.system(size: 16))
        }
        Spacer()
        Text(config.title)
          .font(.system(size: 16, weight: .medium))
        Spacer()
        Button {
          withAnimation {
            onSelect?(selectedGroups)
            sheet.close()
          }
        } label: {
          Text("确定")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(selectedGroups.isEmpty ? .secondary : .blue)
        }
        .disabled(selectedGroups.isEmpty)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(Color.white)

      Divider()
        .background(Color.gray.opacity(0.1))

      if isEmpty {
        VStack(spacing: 24) {
          Spacer()

          Image(systemName: "ticket")
            .font(.system(size: 52))
            .foregroundColor(.secondary.opacity(0.7))

          VStack(spacing: 8) {
            Text("该产品可用优惠码")
              .font(.system(size: 16, weight: .medium))
              .foregroundColor(.secondary)
          }

          Button {
            withAnimation {
              sheet.close()
              router.navigate(to: .createPromotion)
            }
          } label: {
            Text("去创建")
              .font(.system(size: 16, weight: .medium))
              .foregroundColor(.white)
              .frame(width: 120, height: 40)
              .background(
                RoundedRectangle(cornerRadius: 20)
                  .fill(Color.blue)
              )
          }
          .buttonStyle(.plain)

          Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
      } else {
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(groupCodeCounts, id: \.group) { group, total, usable in
              Button {
                Tap.shared.play(.light)
                withAnimation(.spring) {
                  if usable > 0 {
                    if selectedGroups.contains(group) {
                      selectedGroups.removeAll { $0 == group }
                    } else {
                      if !config.allowMultipleSelection {
                        selectedGroups.removeAll()
                      }
                      selectedGroups.append(group)
                    }
                  }
                }
              } label: {
                HStack(spacing: 16) {
                  VStack(alignment: .leading, spacing: 6) {
                    Text(group)
                      .font(.system(size: 16, weight: .medium))
                      .foregroundColor(.primary)
                    HStack(spacing: 6) {
                      Text("共\(total)个")
                      Text("•")
                        .foregroundColor(.gray.opacity(0.5))
                      Text("可用\(usable)个")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary.opacity(0.8))
                  }

                  Spacer()

                  ZStack {
                    Circle()
                      .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1.5)
                      .frame(width: 20, height: 20)
                      .opacity(selectedGroups.contains(group) ? 0 : 1)

                    Image(systemName: "checkmark.circle.fill")
                      .font(.system(size: 20, weight: .medium))
                      .foregroundColor(.blue)
                      .opacity(selectedGroups.contains(group) ? 1 : 0)
                      .scaleEffect(selectedGroups.contains(group) ? 1 : 0.8)
                  }
                  .animation(
                    .interactiveSpring(response: 0.2, dampingFraction: 0.7), value: selectedGroups)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                  RoundedRectangle(cornerRadius: 10)
                    .fill(
                      selectedGroups.contains(group)
                        ? Color.blue.opacity(0.05)
                        : .white
                    )
                    .animation(.easeOut(duration: 0.2), value: selectedGroups)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(
                      selectedGroups.contains(group)
                        ? Color.blue.opacity(0.1)
                        : Color.gray.opacity(0.08),
                      lineWidth: 1
                    )
                    .animation(.easeOut(duration: 0.2), value: selectedGroups)
                )
              }
              .disabled(usable == 0)
              .opacity(usable > 0 ? 1 : 0.5)
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
      }
    }
    .onAppear {
      Task {
        codes = await promotionService.loadCodes(productId: productId)
      }
    }
  }
}
