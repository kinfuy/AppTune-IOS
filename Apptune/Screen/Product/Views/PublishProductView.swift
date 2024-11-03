import SwiftUI

struct PublishProductView: View {
  @StateObject private var viewModel: PublishProductViewModel = PublishProductViewModel()
  @EnvironmentObject private var router: Router

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // 产品图片上传区域
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "#f4f4f4"))
            .frame(height: 200)

          if let image = viewModel.productImage {
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
              .frame(height: 200)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          } else {
            VStack {
              Image(systemName: "photo.badge.plus")
                .font(.system(size: 40))
              Text("添加产品图片")
                .font(.subheadline)
            }
            .foregroundColor(.gray)
          }
        }
        .onTapGesture {
          viewModel.showImagePicker = true
        }

        // 发布按钮
        Button(action: {
          Task {
            await viewModel.publishProduct()
          }
        }) {
          Text("发布产品")
                .frame(height: 38)
                .buttonStyle(.black)
        }
        .padding(.horizontal)
        .padding(.top, 20)
      }
      .padding()
    }
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle("发布产品")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(
        action: { router.back() },
        label: {
          HStack {
            SFSymbol.back
          }
          .foregroundStyle(Color(hex: "#333333"))
        }
      )
    )
  }
}

