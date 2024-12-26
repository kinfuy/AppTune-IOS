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
  @State private var showingSuggestions = false
  @State private var hasSearched = false

  @FocusState private var isFocused: Bool
  private let searchHistory = SearchHistory()
  @State private var suggestions: [String] = []

  var body: some View {
    VStack(spacing: 0) {
      // 优化搜索头部
      HStack(spacing: 12) {
        // 优化搜索框
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray.opacity(0.6))
            .font(.system(size: 16))

          TextField("搜索活动标题、描述", text: $searchText)
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .submitLabel(.search)
            .focused($isFocused)
            .onChange(of: searchText) { newValue in
              updateSuggestions()
            }
            .onSubmit {
              search()
            }

          if !searchText.isEmpty {
            Button(action: {
              searchText = ""
              searchResults = []
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

        // 优化取消按钮
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
          // 搜索历史或建议
          if !hasSearched {
            if searchText.isEmpty {
              // 搜索历史
              VStack(alignment: .leading, spacing: 16) {
                HStack {
                  Text("搜索历史")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#666666"))
                  Spacer()
                  if !suggestions.isEmpty {
                    Button(action: {
                      searchHistory.clearHistory()
                      suggestions = []
                    }) {
                      HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("清除")
                          .font(.system(size: 13))
                      }
                      .foregroundColor(Color(hex: "#999999"))
                    }
                  }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                if suggestions.isEmpty {
                  Text("暂无搜索历史")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#999999"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                } else {
                  ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                      ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                          searchText = suggestion
                          performSearch(keyword: suggestion)
                        }) {
                          HStack(spacing: 12) {
                            Image(systemName: "clock")
                              .font(.system(size: 14))
                              .foregroundColor(Color(hex: "#999999"))
                            Text(suggestion)
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
                  }
                }
              }
              .background(Color.white)
            } else {
              // 搜索建议
              VStack {
                if showingSuggestions {
                  ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                      ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                          searchText = suggestion
                          performSearch(keyword: suggestion)
                        }) {
                          HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                              .font(.system(size: 14))
                              .foregroundColor(Color(hex: "#999999"))
                            Text(suggestion)
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
                  }
                }
              }
              .frame(maxWidth: .infinity)
              .background(Color.white)
            }
          }

          // 搜索结果或加载状态
          if hasSearched {
            if isSearching {
              Spacer()
              ProgressView()
                .scaleEffect(0.8)
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
    suggestions = searchHistory.getSearchHistory()
  }

  // 更新搜索建议
  private func updateSuggestions() {
    if searchText.isEmpty {
      suggestions = searchHistory.getSearchHistory()
      hasSearched = false
      searchResults = []
    } else {
      suggestions = searchHistory.getSearchHistory().filter {
        $0.localizedCaseInsensitiveContains(searchText)
      }
      showingSuggestions = !suggestions.isEmpty
      hasSearched = false  // 重置搜索状态
    }
  }

  // 执行搜索
  private func performSearch(keyword: String) {
    guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }

    showingSuggestions = false
    isSearching = true
    hasSearched = true
    searchHistory.addSearchHistory(keyword)

    Task {
      searchResults = await activeService.searchActive(keyword: keyword)
      isSearching = false
    }
  }

  // 搜索方法
  private func search() {
    performSearch(keyword: searchText)
  }
}

#Preview {
  SearchActiveView()
    .environmentObject(ActiveService())
}
