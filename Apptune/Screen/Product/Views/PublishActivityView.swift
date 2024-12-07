import SwiftUI

// 添加模式枚举
enum PublishMode {
  case quick  // 快捷模式
  case pro  // 专业模式
}

struct PublishActivityView: View {
  @StateObject private var viewModel = PublishActivityViewModel()
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var producttService: ProductService
  @EnvironmentObject private var sheet: SheetManager

  // 添加步骤状态
  @State private var step: PublishStep = .selectProduct
  // 选中的产品
  @State private var selectedProduct: ProductInfo?

  // 添加模式状态
  @State private var publishMode: PublishMode = .quick

  var body: some View {
    Group {
      if producttService.selfProducts.isEmpty {
        noProductsView
      } else {
        switch step {
        case .selectProduct:
          selectProductView
        case .editActivity:
          activityForm
        }
      }
    }
    .background(Color(hex: "#f4f4f4"))
    .navigationBarBackButtonHidden()
    .navigationBarTitle(step == .selectProduct ? "选择产品" : "发布活动")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(
      leading: Button(
        action: {
          if step == .editActivity {
            // 如果在编辑页面,返回选择产品
            step = .selectProduct
          } else {
            router.back()
          }
        },
        label: {
          Group {
            HStack {
              SFSymbol.back
            }
          }
          .foregroundStyle(Color(hex: "#333333"))
        }),
      trailing: step == .editActivity
        ? Button(
          action: {
            sheet.show(
              .activityTemplates(onSelect: { template in
                viewModel.initFromTemplate(template)
              }))
          },
          label: {
            Text("模板库")
              .font(.system(size: 16))
              .foregroundStyle(Color(hex: "#333333"))
          }
        ) : nil
    )
  }

  // 选择产品视图
  private var selectProductView: some View {
    ScrollView {
      VStack(spacing: 16) {
        ForEach(producttService.selfProducts) { product in
          ProductCard(product: product)
            .onTapGesture {
              selectedProduct = product
              viewModel.product = product
              step = .editActivity
            }
        }
      }
      .padding()
    }
  }

  // 产品卡片组件
  private struct ProductCard: View {
    let product: ProductInfo

    var body: some View {
      HStack(spacing: 16) {
        ImgLoader(product.icon)
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 12))

        VStack(alignment: .leading, spacing: 8) {
          Text(product.name)
            .font(.headline)
            .foregroundColor(Color(hex: "#333333"))

          Text(product.description)
            .font(.subheadline)
            .foregroundColor(.gray)
            .lineLimit(2)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .foregroundColor(.gray)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(color: .gray.opacity(0.05), radius: 8)
    }
  }

  // 没有产品时的引导视图
  private var noProductsView: some View {
    VStack(spacing: 24) {
      // 图标部分
      VStack(spacing: 16) {
        ImgLoader("empty")
          .frame(width: /*@START_MENU_TOKEN@*/ 100 /*@END_MENU_TOKEN@*/, height: 100)
      }

      // 文字说明部分
      VStack(spacing: 12) {
        Text("还没有创建产品")
          .font(.title2)
          .fontWeight(.medium)

        Text("创建一个产品开始发布精彩活动吧")
          .font(.subheadline)
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }

      // 按钮部分
      Text("创建产品")
        .onTapGesture {
          router.navigate(to: .publishProduct)
        }
        .buttonStyle(.black)
        .frame(height: 42)
    }
    .padding(30)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .shadow(color: .gray.opacity(0.08), radius: 12)
    )
    .padding()
  }

  // 活动表单视图
  private var activityForm: some View {
    VStack(spacing: 0) {
      // 步骤指示器
      HStack {
        Circle()
          .fill(Color.black)
          .frame(width: 24, height: 24)
          .overlay(Text("1").foregroundColor(.white))

        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .frame(height: 1)

        Circle()
          .fill(Color.black)
          .frame(width: 24, height: 24)
          .overlay(Text("2").foregroundColor(.white))
      }
      .padding(.horizontal, 40)
      .padding(.vertical)

      // 显示已选产品(不可选择)
      if let product = selectedProduct {
        HStack(spacing: 16) {
          ImgLoader(product.icon)
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))

          VStack(alignment: .leading, spacing: 4) {
            Text(product.name)
              .font(.headline)
            Text(product.description)
              .font(.subheadline)
              .foregroundColor(.gray)
              .lineLimit(1)
          }
          Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.05), radius: 8)
        .padding(.horizontal)
      }

      // 添加模式切换 Tab
      HStack(spacing: 0) {
        ForEach([PublishMode.quick, .pro], id: \.self) { mode in
          Button(action: {
            withAnimation {
              publishMode = mode
            }
          }) {
            VStack(spacing: 8) {
              Text(mode == .quick ? "快捷" : "专业")
                .font(.headline)
                .foregroundColor(publishMode == mode ? .black : .gray)
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(.vertical, 8)
      .background(Color.white)
      .padding(.horizontal)
      .padding(.top)

      ScrollView {
        VStack(spacing: 20) {
          // 基础信息部分
          Group {
            HStack {
              Text("活动信息")
                .font(.headline)
                .foregroundColor(Color(hex: "#666666"))
              Spacer()
            }
            .padding(.horizontal)

            // 活动信息卡片
            basicInfoCard
          }

          // 专业模式才显示的配置
          if publishMode == .pro {
            Group {
              // 奖励说明
              rewardCard

              // 高级配置
              advancedConfigCard
            }
          }
        }
        .padding(.top)
      }

      // 底部按钮
      HStack(spacing: 12) {
        // 上一步按钮
        Button(action: {
          step = .selectProduct
        }) {
          Image(systemName: "chevron.left")
            .frame(width: 42, height: 42)
            .background(Color.white)
            .foregroundColor(.gray)
        }

        // 预览按钮
        Button(action: {
          sheet.show(
            .activityPreview(
              product: selectedProduct,
              title: viewModel.title,
              description: viewModel.description,
              images: viewModel.images,
              limit: viewModel.limit,
              endAt: viewModel.endAt,
              isAutoEnd: viewModel.isAutoEnd,
              publishMode: publishMode
            ))
        }) {
          Image(systemName: "eye")
            .frame(width: 42, height: 42)
            .background(Color.white)
            .foregroundColor(.gray)
            .cornerRadius(8)
        }

        // 发布按钮
        Button(action: {
          if viewModel.isLoading { return }
          if let error = viewModel.checkValid() {
            NoticeManager.shared.openNotice(open: .toast(error))
            return
          }
          Task {
            await viewModel.publishActivity()
            router.back()
            NoticeManager.shared.openNotice(
              open: .toast(Toast(msg: "活动发布成功"))
            )
          }
        }) {
          Text("发布活动")
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(viewModel.isLoading)
      }
      .padding()
    }
  }

  // 基础信息卡片
  private var basicInfoCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      CustomTextField(
        text: $viewModel.title,
        placeholder: "活动标题"
      )

      Divider()

      // 图片上传部分
      VStack(alignment: .leading) {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            // 上传按钮
            Button(action: {}) {
              Rectangle()
                .fill(Color(hex: "#f4f4f4"))
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                .overlay(
                  VStack(spacing: 8) {
                    Image(systemName: "plus")
                      .font(.system(size: 32))
                  }
                  .foregroundColor(.gray)
                )
            }

            // 已上传图片
            if !viewModel.images.isEmpty {
              ForEach(viewModel.images, id: \.self) { image in
                ImgLoader(image)
                  .frame(width: 100, height: 100)
                  .clipped()
                  .cornerRadius(8)
                  .overlay(
                    Button(action: {
                      // 删除图片
                    }) {
                      Image(systemName: "xmark")
                        .padding(4)
                        .background(.black.opacity(0.7))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                    }
                    .padding(4),
                    alignment: .topTrailing
                  )
              }
            }
          }
        }
      }

      CustomTextField(
        text: $viewModel.description,
        placeholder: "活动描述",
        isMultiline: true
      )
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.05), radius: 8)
    .padding(.horizontal)
  }

  // 奖励说明卡片
  private var rewardCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("活动奖励")
          .font(.subheadline)
          .foregroundColor(Color(hex: "#666666"))
        Spacer()
      }

      // 这里可以添加奖励配置的具体内容
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .gray.opacity(0.05), radius: 8)
    .padding(.horizontal)
  }

  // 高级配置卡片
  private var advancedConfigCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("高级配置")
        .font(.headline)
        .foregroundColor(Color(hex: "#666666"))
        .padding(.horizontal)

      VStack(alignment: .leading, spacing: 16) {
        // 人数限制
        VStack(alignment: .leading, spacing: 8) {
          Text("参与人数限制")
            .font(.subheadline)
            .foregroundColor(Color(hex: "#666666"))

          TextField("不限制人数", value: $viewModel.limit, format: .number)
            .keyboardType(.numberPad)
        }

        // 结束时间设置
        VStack(alignment: .leading, spacing: 8) {
          if viewModel.isAutoEnd {
            DatePicker(
              "结束时间",
              selection: $viewModel.endAt ?? Date(),
              in: Date()...,
              displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
          }
        }
      }
      .padding()
      .background(Color.white)
      .cornerRadius(12)
      .shadow(color: .gray.opacity(0.05), radius: 8)
      .padding(.horizontal)
    }
  }
}

// 自定义输入框组件
struct CustomTextField: View {
  @Binding var text: String
  let placeholder: String
  var isMultiline: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if isMultiline {
        TextEditor(text: $text)
          .frame(height: 180)
          .padding(8)
          .cornerRadius(8)
          .overlay(
            VStack {
              HStack {
                if text.isEmpty {
                  Text(placeholder)
                    .foregroundColor(.gray)
                }
                Spacer()
              }
              Spacer()
            }
          )
      } else {
        TextField(placeholder, text: $text)
          .cornerRadius(8)
      }
    }
  }
}

// 添加产品卡片组件
struct ProductSelectCard: View {
  let product: ProductInfo
  let isSelected: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // 产品图标
      HStack {
        ImgLoader(product.icon)
          .frame(width: 42, height: 42)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.gray.opacity(0.1), lineWidth: 1)
          )

        Spacer()
      }
      // 产品名称
      Text(product.name)
        .font(.subheadline)
        .foregroundColor(Color(hex: "#333333"))
        .lineLimit(1)
    }
    .frame(width: 100)
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white)
        .shadow(color: .gray.opacity(0.05), radius: 8)
    )
    .overlay {
      if isSelected {
        VStack {
          HStack {
            Spacer()
            SFSymbol.success
              .font(.system(size: 12))
              .padding(4)
              .background(.black.opacity(0.7))
              .clipShape(RoundedCorners(topLeft: 4, topRight: 12, bottomLeft: 4, bottomRight: 4))
              .foregroundColor(.white)
          }
          Spacer()
        }
      }
    }
  }
}

// 发布步骤枚举
enum PublishStep {
  case selectProduct  // 选择产品
  case editActivity  // 编辑活动
}

#Preview("Empty State") {
  let router = Router()
  let noticeManager = NoticeManager()
  let sheetManager = SheetManager()
  let productService = ProductService()

  // 不添加任何产品，显示空状态
  productService.selfProducts = []

  return NavigationStack {
    PublishActivityView()
      .environmentObject(router)
      .environmentObject(noticeManager)
      .environmentObject(sheetManager)
      .environmentObject(productService)
  }
}

#Preview("Multiple Products") {
  let router = Router()
  let noticeManager = NoticeManager()
  let sheetManager = SheetManager()
  let productService = ProductService()

  // 添加多个测试产品
  productService.selfProducts = [
    ProductInfo(
      id: "1", name: "产品1", description: "描述1", icon: "https://picsum.photos/200", link: "",
      category: "", price: nil, createTime: Date(), status: 1, developer: "开发者1"),
    ProductInfo(
      id: "2", name: "产品2", description: "描述2", icon: "https://picsum.photos/200", link: "",
      category: "", price: nil, createTime: Date(), status: 1, developer: "开发者2"),
    ProductInfo(
      id: "3", name: "产品3", description: "描述3", icon: "https://picsum.photos/200", link: "",
      category: "", price: nil, createTime: Date(), status: 1, developer: "开发者3"),
  ]

  return NavigationStack {
    PublishActivityView()
      .environmentObject(router)
      .environmentObject(noticeManager)
      .environmentObject(sheetManager)
      .environmentObject(productService)
  }
}
