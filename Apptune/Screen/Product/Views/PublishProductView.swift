import SwiftUI

struct PublishProductView: View {
  var product: ProductInfo?
  @StateObject private var viewModel: PublishProductViewModel = PublishProductViewModel()
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var notice: NoticeManager
  @EnvironmentObject private var sheet: SheetManager
  @EnvironmentObject private var productService: ProductService

  var EditView: some View {
    VStack {
      Section(content: {
        VStack {
          VStack {
            HStack {
              if viewModel.iconUrl != "" {
                ImgLoader(viewModel.iconUrl)
                  .frame(width: 80, height: 80)
                  .cornerRadius(16)
                  .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
              } else {
                RoundedRectangle(cornerRadius: 16)
                  .fill(Color.gray.opacity(0.1))
                  .frame(width: 80, height: 80)
                  .overlay(
                    Image(systemName: "photo")
                      .font(.system(size: 30))
                      .foregroundColor(.gray)
                  )
              }
            }
            .onTapGesture {
              sheet.show(
                .imagePicker(onSelect: { image in
                  viewModel.selectedImage = image
                }))
            }
          }
          .padding(.bottom, 16)
          VStack {
            HStack {
              Text("产品名称")
                .foregroundColor(.gray)
              Spacer()
            }
            TextField("", text: $viewModel.productName, prompt: Text("产品名称"))
              .multilineTextAlignment(.leading)
              .padding(8)
              .background(Color(hex: "#fafafa"))
              .cornerRadius(4)
          }
          .padding(.bottom, 16)
          VStack {
            HStack {
              Text("链接")
                .foregroundColor(.gray)
              Spacer()
            }
            TextField("", text: $viewModel.link, prompt: Text("产品名称"))
              .multilineTextAlignment(.leading)
              .padding(8)
              .background(Color(hex: "#fafafa"))
              .cornerRadius(4)
          }
        }
        .padding()
        .background(.white)
        .cornerRadius(8)
      })
      Section(content: {
        VStack {
          VStack {
            HStack {
              Text("描述")
                .foregroundColor(.gray)
              Spacer()
            }
            TextEditor(text: $viewModel.productDescription)
              .frame(height: 120)
              .padding(4)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color(.systemBackground))
              )
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray.opacity(0.2), lineWidth: 1)
              )
          }
          HStack {
            Text("分组")
              .foregroundColor(.gray)
            Spacer()
            Picker(
              "", selection: $viewModel.category,
              content: {
                ForEach(Catalog.allCases.filter({ $0 != .all }), id: \.rawValue) { p in
                  Text(p.label)
                    .tag(p)
                }
              })
          }
          .frame(height: 36)
        }
        .padding()
        .background(.white)
        .cornerRadius(8)
      })
    }
    .frame(maxWidth: .infinity)
  }

  var body: some View {
    VStack {
      ScrollView {
        VStack {
          Section {
            HStack {
              Button(action: {
                sheet.show(
                  .appStoreSearch(
                    onSubmit: { app in
                      // 处理选中的 app
                      viewModel.handleSelectedApp(app)
                    }
                  ))
              }) {
                Label("从 App Store 导入", systemImage: "magnifyingglass")
                  .foregroundColor(.black)
              }
              Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.white)
            .cornerRadius(8)
          }
          .padding(.bottom, 12)
          EditView
        }
        .padding()
      }
      Spacer()
      VStack {
        Text(product == nil ? "发布产品" : "更新产品")
          .loadingButton(loading: viewModel.isLoading)
          .buttonStyle(.black)
          .frame(height: 42)
          .onTapGesture {
            if viewModel.isLoading {
              return
            }
            if let error = viewModel.checkValid() {
              notice.open(open: .toast(error))
              return
            }
            Tap.shared.play(.light)
            Task {
              await viewModel.publishProduct(success: {
                Task {
                  await productService.loadPendingProductReviews()
                  await productService.loadProducts(refresh: true)
                }
                router.back()
              })
            }
          }
          .frame(height: 38)
      }.padding()
    }
    .onAppear {
      Task {
        await productService.loadProducts(refresh: true)
      }
      if let product = product {
        viewModel.editProduct(product: product)
      }
    }
    .customNavigationBar(title: product == nil ? "发布产品" : "编辑产品", router: router)
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

#Preview {
  NavigationStack {
    PublishProductView(product: nil)
      .environmentObject(Router())
      .environmentObject(NoticeManager())
      .environmentObject(SheetManager())
  }
}
