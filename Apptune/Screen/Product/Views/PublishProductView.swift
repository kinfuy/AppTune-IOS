import SwiftUI

struct PublishProductView: View {
  @StateObject var viewModel: PublishProductViewModel = PublishProductViewModel.shared
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sheet: SheetManager

  var body: some View {
      VStack{
          Form {
            // App Store 导入部分
            Section {
              Button(action: {
                sheet.show(.appStoreSearch) {
                  print("App Store search closed")
                }
              }) {
                Label("从 App Store 导入", systemImage: "magnifyingglass")
                  .foregroundColor(.theme)
              }

            }

            // 产品基本信息
            Section(header: Text("产品信息")) {
              // 图标预览
              if viewModel.iconUrl != "" {
                ImgLoader(viewModel.iconUrl)
                  .frame(width: 60, height: 60)
                  .cornerRadius(12)
              }

              // 产品名称
              TextField("产品名称", text: $viewModel.productName)
                .textInputAutocapitalization(.never)

              // 产品描述
              TextEditor(text: $viewModel.productDescription)
                .frame(height: 200)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }

            // 价格和库存信息
            Section(header: Text("其他信息")) {
              TextField("链接", text: $viewModel.link)
            }
           
          }
          Spacer()
          Button("发布") {
              Task {
                await viewModel.publishProduct()
              }
          }
              .primaryButton()
              .disabled(viewModel.isLoading || !viewModel.isValid)
      }
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationTitle("发布产品")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(action: { router.back() }) {
        Label("返回", systemImage: "chevron.left")
          .foregroundStyle(Color(hex: "#333333"))
      }
    )
    .overlay(
      Group {
        if viewModel.isLoading {
          ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
        }
      }
    )
  }
}
