import SwiftUI

struct PublishActivityView: View {
    @StateObject private var viewModel = PublishActivityViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var producttService: ProductService
    @EnvironmentObject private var sheet: SheetManager
    // 添加选中产品的状态
    @State private var selectedProduct: ProductInfo?

    // 添加日期验证逻辑
    private var isDateValid: Bool {
        return viewModel.startTime < viewModel.endTime
    }

    var body: some View {
        Group {
            if producttService.selfProducts.isEmpty {
                noProductsView
            } else {
                activityForm
            }
        }
        .background(Color(hex: "#f4f4f4"))
        .navigationBarBackButtonHidden()
        .navigationBarTitle("发布活动")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(
                action: {
                    router.back()
                },
                label: {
                    Group {
                        HStack {
                            SFSymbol.back
                        }
                    }
                    .foregroundStyle(Color(hex: "#333333"))
                }),
            trailing: Button(
                action: {
                    if(producttService.selfProducts.isEmpty) {return}
                    sheet.show(.activityTemplates(onSelect: { temp in
                        print(temp)

                    }))
                },
                label: {
                    Text("模板库")
                        .font(.system(size: 16))
                        .foregroundStyle(producttService.selfProducts.isEmpty ?.gray : Color(hex: "#333333"))
                }
            )
        )
    }

    // 没有产品时的引导视图
    private var noProductsView: some View {
        VStack(spacing: 24) {
            // 图标部分
            VStack(spacing: 16) {
                ImgLoader("empty")
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
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
        ScrollView {
            VStack(spacing: 20) {
                // 产品选择卡片
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择产品")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#666666"))

                    // 产品选择列表
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(producttService.selfProducts) { product in
                                ProductSelectCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id
                                )
                                .onTapGesture {
                                    selectedProduct = product
                                    viewModel.selectedProductId = product.id
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)

                // 活动信息卡片
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 16) {
                        // 活动信息输入
                        VStack(spacing: 16) {
                            CustomTextField(
                                text: $viewModel.activityName,
                                placeholder: "活动标题"
                            )

                            CustomTextField(
                                text: $viewModel.activityDescription,
                                placeholder: "活动描述",
                                isMultiline: true
                            )

                            // 标签选择器
                            TagPicker(tag: .constant(Tag()))

                            // 时间选择部分
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.05), radius: 8)
                }
                .padding(.horizontal)

                HStack {
                    VStack(spacing: 4) {
                        SFSymbol.eye
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("预览")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                    // 发布按钮
                    Text("发布活动")
                        .onTapGesture {
                            Task {
                                try await viewModel.publishActivity()
                            }
                        }
                        .buttonStyle(.black)
                }
                .padding(.horizontal)
            }
        }
        .background(Color(hex: "#f8f9fa"))
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
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(hex: "#f8f9fa"))
                    .cornerRadius(8)
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                                    .padding(.top, 12)
                            }
                        }
                    )
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color(hex: "#f8f9fa"))
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
            ImgLoader(product.icon)
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )

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
                .fill(isSelected ? Color.theme.opacity(0.1) : Color.white)
                .shadow(color: .gray.opacity(0.05), radius: 8)
        )
    }
}

#Preview {
    NavigationStack {
        PublishActivityView()
            .environmentObject(Router())
            .environmentObject(NoticeManager())
            .environmentObject(SheetManager())
            .environmentObject(ProductService())
    }
}
