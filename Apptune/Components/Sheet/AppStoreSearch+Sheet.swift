//
//  AppStoreSearch+Sheet.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/3.
//

import SwiftUI

struct AppStoreSearchSheet: View {
  @EnvironmentObject var sheet: SheetManager
  @EnvironmentObject var notice: NoticeManager
  @StateObject var viewModel: PublishProductViewModel = PublishProductViewModel()
  @State private var searchText = ""
  var onSubmit: ((_ app: AppSearchInfo) -> Void)?
  var onCancel: (() -> Void)?

  var body: some View {
    VStack(spacing: 0) {
      // 顶部导航栏
      HStack {
        Button("取消") {
          if let cancel = onCancel {
            cancel()
          }
          sheet.close()
        }
        .foregroundColor(.gray)

        Spacer()

        Text("App Store 搜索")
          .font(.headline)

        Spacer()

        Button("确认") {
          if let selectedApp = viewModel.selectedApp {
            viewModel.selectApp(selectedApp)
            if let onSubmit = onSubmit {
              onSubmit(selectedApp)
            }
            sheet.close()
          }
        }
        .foregroundColor(viewModel.selectedApp != nil ? .theme : .gray)
        .disabled(viewModel.selectedApp == nil)
      }
      .padding(.horizontal)
      .padding(.top, 16)
      .padding(.bottom, 16)

      // 搜索区域
      HStack(spacing: 12) {
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)

          TextField("输入应用名称", text: $searchText)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)

        Button("搜索") {
          if searchText.isEmpty {
            notice.open(
              open: .toast(
                Toast(
                  msg: "请输入搜索内容"
                )))
            return
          }

          Task {
            await viewModel.fetchAppStoreInfo(name: searchText)
          }
        }
        .buttonStyle(.theme, .white, 8)
        .frame(width: 60, height: 32)
      }
      .padding(.horizontal)
      .padding(.vertical, 12)

      // 搜索结果区域
      ZStack {
        if viewModel.isLoading {
          LoadingComponent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.searchResults.isEmpty {
          ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
              ForEach(viewModel.searchResults) { app in
                AppResultCard(
                  app: app,
                  isSelected: viewModel.selectedApp?.id == app.id
                ) {
                  viewModel.selectedApp = app
                }
              }
            }
            .padding()
          }
        } else {
          VStack(spacing: 12) {
            if viewModel.iconUrl == "" {
              Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
              Text("暂无搜索结果")
                .foregroundColor(.gray)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .dismissKeyboardOnTap()
    }
  }
}

// 搜索结果卡片组件
struct AppResultCard: View {
  let app: AppSearchInfo
  let isSelected: Bool
  let onSelect: () -> Void

  var body: some View {
    Button(action: onSelect) {
      HStack(spacing: 12) {
        // App 图标
        AsyncImage(url: URL(string: app.iconUrl)) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          Color.gray.opacity(0.2)
        }
        .frame(width: 56, height: 56)
        .cornerRadius(12)

        // App 信息
        VStack(alignment: .leading, spacing: 4) {
          Text(app.name)
            .font(.headline)
            .foregroundColor(.primary)
            .lineLimit(1)

          Text(app.developer)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)

          Text(app.category)
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        // 选中状态指示器
        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.theme)
            .font(.system(size: 20))
        } else {
          Image(systemName: "circle")
            .foregroundColor(.gray)
            .font(.system(size: 20))
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.systemBackground))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(isSelected ? Color.theme : Color.clear, lineWidth: 2)
          )
      )
      .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  VStack {
  }
  .sheet(isPresented: .constant(true)) {
    AppStoreSearchSheet()
      .environmentObject(Router())
      .environmentObject(SheetManager())
      .environmentObject(NoticeManager())
  }
}
