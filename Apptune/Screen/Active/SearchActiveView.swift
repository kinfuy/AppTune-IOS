//
//  SearchActiveView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/26.
//

import SwiftUI

struct SearchActiveView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var activeService: ActiveService
  @State private var searchText = ""
  @State private var isSearching = false
  @State private var searchResults: [ActiveInfo] = []
  @State private var hasSearched = false
  @State private var searchHistory: [String] = []  // 只保留搜索历史

  @FocusState private var isFocused: Bool
  private let searchHistoryUtil = SearchHistory()

  var body: some View {
    VStack(spacing: 0) {
      // 搜索头部
      HStack(spacing: 12) {
        // 搜索框
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray.opacity(0.6))
            .font(.system(size: 16))

          TextField("搜索活动标题、描述", text: $searchText)
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .submitLabel(.search)
            .focused($isFocused)
            .onSubmit {
              executeSearch(keyword: searchText)
            }

          if !searchText.isEmpty {
            Button(action: {
              searchText = ""
              searchResults = []
              hasSearched = false
            }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray.opacity(0.6))
                .font(.system(size: 16))
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)

        Button("取消") {
          router.back()
        }
        .font(.system(size: 15))
        .foregroundColor(Color(hex: "#666666"))
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(.white)
      .shadow(color: .black.opacity(0.05), radius: 1, y: 1)

      // 内容区域
      ZStack {
        Color(UIColor.systemGray6)
          .ignoresSafeArea()

        VStack(spacing: 0) {
          // 搜索历史
          if !hasSearched && !isSearching && !searchHistory.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
              // 标题和清除按钮
              HStack {
                Text("搜索历史")
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(Color(hex: "#666666"))
                Spacer()
                Button(action: {
                  searchHistoryUtil.clearHistory()
                  searchHistory = []
                }) {
                  HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("清除")
                      .font(.system(size: 13))
                  }
                  .foregroundColor(Color(hex: "#999999"))
                }
              }
              .padding(.horizontal)
              .padding(.top, 12)

              // 搜索历史列表
              ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                  ForEach(searchHistory, id: \.self) { item in
                    SearchItemRow(
                      text: item,
                      icon: "clock"
                    ) {
                      executeSearch(keyword: item)
                    }
                  }
                }
              }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
          }

          // 搜索结果或加载状态
          if hasSearched {
            if isSearching {
              Spacer()
              LoadingComponent()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
              Spacer()
            } else {
              if searchResults.isEmpty {
                EmptyView(text: "未找到相关活动", image: "empty")
              } else {
                ScrollView {
                  LazyVStack(spacing: 16) {
                    ForEach(searchResults, id: \.id) { active in
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
                      .contentShape(Rectangle())
                      .onTapGesture {
                        router.navigate(to: .activeDetail(active: active), isReplace: true)
                      }
                    }
                  }
                  .padding()
                }
              }
            }
          }

          Spacer(minLength: 0)
        }
      }
    }
    .navigationBarHidden(true)
    .onAppear {
      isFocused = true
      loadSearchHistory()
    }
  }

  // 加载搜索历史
  private func loadSearchHistory() {
    searchHistory = searchHistoryUtil.getSearchHistory()
  }

  // 统一的搜索执行方法
  private func executeSearch(keyword: String) {
    guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }

    Task { @MainActor in
      // 1. 更新状态
      searchText = keyword
      hasSearched = true
      isSearching = true
      searchResults = []

      // 2. 添加到历史
      searchHistoryUtil.addSearchHistory(keyword)
      searchHistory = searchHistoryUtil.getSearchHistory()

      // 3. 执行搜索
      searchResults = await activeService.searchActive(keyword: keyword)

      // 4. 更新状态
      isSearching = false
    }
  }
}

// 抽取搜索项行视图
private struct SearchItemRow: View {
  let text: String
  let icon: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundColor(Color(hex: "#999999"))
        Text(text)
          .font(.system(size: 14))
          .foregroundColor(Color(hex: "#333333"))
        Spacer()
      }
      .padding(.horizontal)
      .padding(.vertical, 12)
      .contentShape(Rectangle())
    }
    Divider()
      .padding(.leading)
  }
}

#Preview {
  SearchActiveView()
    .environmentObject(ActiveService())
}
