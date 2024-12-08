import SwiftUI

// 添加模式枚举
enum PublishMode {
    case quick // 快捷模式
    case pro // 专业模式
}

struct PublishActivityView: View {
    @StateObject private var viewModel = PublishActivityViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject var notice: NoticeManager
    @EnvironmentObject private var producttService: ProductService
    @EnvironmentObject private var sheet: SheetManager

    // 添加步骤状态
    @State private var step: PublishStep = .selectProduct
    // 选中的产品
    @State private var selectedProduct: ProductInfo?

    // 添加模式状态
    @State private var publishMode: PublishMode = .quick

    // 上传图片
    private func uploadImage(_ image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
        do {
            let url = try await FileAPI.shared.uploadAvatar(imageData)
            return url
        } catch {
            notice.openNotice(open: .toast("图片上传失败"))
            return nil
        }
    }

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
                    .frame(width: 100, height: 100)
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
                                .font(.system(size: 16))
                                .foregroundColor(publishMode == mode ? .black : Color(hex: "#999999"))
                                .frame(height: 38)
                            // 添加底部指示条
                            Rectangle()
                                .fill(publishMode == mode ? Color.black : Color.clear)
                                .frame(height: 2)
                                .padding(.horizontal, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
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
                            rewardCardView

                            // 高级配置
                            advancedConfigCard
                        }
                    }
                }
                .padding(.top)
            }

            VStack(spacing: 16) {
                // 存为模板开关
                HStack(spacing: 12) {
                    Text("存为模板")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#666666"))

                    Spacer()

                    Toggle("", isOn: $viewModel.isTemplate)
                        .labelsHidden()
                        .tint(.black)
                        .scaleEffect(0.8, anchor: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)

                // 底部按钮组
                HStack(spacing: 12) {
                    // 上一步按钮
                    Button(action: {
                        step = .selectProduct
                    }) {
                        Image(systemName: "chevron.left")
                            .frame(width: 42, height: 42)
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .cornerRadius(8)
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
                            NoticeManager.shared.openNotice(
                                open: .toast(Toast(msg: "活动发布成功"))
                            )
                            router.back()
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
            }
            .padding()
            .background(Color(hex: "#f4f4f4"))
        }
        .dismissKeyboardOnTap()
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
                        Button(action: {
                            sheet.show(
                                .imagePicker(onSelect: { image in
                                    Task {
                                        if let url = await uploadImage(image) {
                                            viewModel.images.append(url)
                                        }
                                    }
                                }))
                        }) {
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
                                            viewModel.images.removeAll { $0 == image }
                                        }) {
                                            SFSymbol.close
                                                .font(.system(size: 12))
                                                .padding(4)
                                                .background(.black.opacity(0.7))
                                                .cornerRadius(4)
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
        .contentShape(Rectangle())
    }

    // 奖励说明卡片
    private var rewardCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("奖励设置")
                .font(.headline)
                .foregroundColor(Color(hex: "#666666"))
                .padding(.horizontal)

            VStack {
                Picker("奖励类型", selection: $viewModel.reward) {
                    Text("自行管理").tag(RewardType.selfManaged)
                    Text("促销码").tag(RewardType.promoCode)
                    Text("积分奖励").tag(RewardType.points)
                }
                .pickerStyle(.segmented)

                // 根据选择的奖励类型显示不同的内容
                VStack{
                    switch viewModel.reward {
                    case .selfManaged:
                        Text("任务奖励将由发布者自行管理")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#666666"))
                    case .promoCode:
                        HStack {
                            Text("管理促销码")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#666666"))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .onTapGesture {
                            // TODO: 导航到促销码管理页面
                        }
                    case .points:
                        VStack {
                            Spacer()
                            EmptyView(text: "敬请期待", image: "nodata", size: 40)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
            }.padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.05), radius: 8)
                .padding(.horizontal)
        }
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
                    Text("参与限制")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#333333"))

                    HStack {
                        Text("人数")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#666666"))
                        Spacer()
                        TextField("输入限制参与人数", value: $viewModel.limit, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 200)
                    }
                }

                // 结束时间设置
                VStack(alignment: .leading, spacing: 8) {
                    Text("时间限制")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#333333"))
                    DatePicker(
                        selection: $viewModel.startAt,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    ) {
                        Text("开始")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#666666"))
                    }
                    HStack {
                        Text("有效期")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#666666"))
                        Spacer()
                        Picker(
                            "", selection: $viewModel.isAutoEnd,
                            content: {
                                Text("永久").tag(false)
                                Text("自定义").tag(true)
                            }
                        )
                        .pickerStyle(.segmented)
                        .frame(width: 190)
                        .allowsHitTesting(true)
                    }
                    if viewModel.isAutoEnd {
                        DatePicker(
                            selection: $viewModel.endAt ?? Date(),
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        ) {
                            Text("结束")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#666666"))
                        }
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
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .frame(height: 180)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .cornerRadius(8)
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color(hex: "#999999"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                    }
                }
            } else {
                TextField(placeholder, text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
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
    case selectProduct // 选择产品
    case editActivity // 编辑活动
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
            category: .effect, price: nil, createTime: Date(), status: 1, developer: "开发者1"),
        ProductInfo(
            id: "2", name: "产品2", description: "描述2", icon: "https://picsum.photos/200", link: "",
            category: .effect, price: nil, createTime: Date(), status: 1, developer: "开发者2"),
        ProductInfo(
            id: "3", name: "产品3", description: "描述3", icon: "https://picsum.photos/200", link: "",
            category: .life, price: nil, createTime: Date(), status: 1, developer: "开发者3"),
    ]

    return NavigationStack {
        PublishActivityView()
            .environmentObject(router)
            .environmentObject(noticeManager)
            .environmentObject(sheetManager)
            .environmentObject(productService)
    }
}
