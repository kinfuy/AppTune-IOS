//
//  CreatePromotionView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/8.
//

import Foundation
import SwiftUI

struct CreatePromotionView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var notice: NoticeManager
    @EnvironmentObject private var sheet: SheetManager
    @EnvironmentObject private var producttService: ProductService
    @StateObject private var viewModel = CreatePromotionViewModel()
    @State private var promoCodes: String = ""

    // CSV上传相关
    @State private var isShowingFilePicker = false
    @State private var csvContent: String?

    // 状态变量
    @State private var isSaving = false

    var body: some View {
        VStack {
            Form {
                // 产品选择区域
                Section("选择产品") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(producttService.selfProducts) { product in
                                ProductSelectItem(
                                    product: product,
                                    isSelected: viewModel.selectedProduct?.id == product.id
                                )
                                .onTapGesture {
                                    viewModel.setSelectedProduct(product)
                                }
                            }
                        }
                    }
                }

                // 基本信息区域
                Section("促销码信息") {
                    TextField("分组名称", text: $viewModel.groupName)

                    CustomTextField(
                        text: $promoCodes,
                        placeholder: "请输入促销码，每行一个",
                        isMultiline: true,
                        height: 80,
                        padding: 0
                    )
                    .onChange(of: promoCodes) { _, newValue in
                        viewModel.addPromoCodes(
                            newValue.components(separatedBy: .newlines)
                        )
                        promoCodes = ""
                    }

                    // 显示已添加的促销码
                    if !viewModel.promoCodes.isEmpty {
                        PromoCodeList(
                            codes: viewModel.promoCodes,
                            duplicateCodes: viewModel.duplicateCodes,
                            onRemove: { code in
                                viewModel.removePromoCode(code)
                            }
                        )
                    }
                }
                // CSV上传区域
                //      Section("批量导入") {
                //        Button("从CSV文件导入") {
                //          isShowingFilePicker = true
                //        }
                //      }
            }
            VStack {
                Text("保存")
                    .loadingButton(loading: viewModel.isLoading)
                    .buttonStyle(.black)
                    .frame(height: 42)
                    .onTapGesture {
                        if viewModel.isLoading {
                            return
                        }
                        if let error = viewModel.checkValid() {
                            notice.openNotice(open: .toast(error))
                            return
                        }
                        Tap.shared.play(.light)
                        Task {
                            await viewModel.createPromotion()
                            notice.openNotice(open: .toast("促销码创建成功"))
                        }
                    }
                    .frame(height: 38)
            }.padding()
        }

        .background(Color(hex: "#f4f4f4"))
        .navigationBarBackButtonHidden()
        .navigationTitle("创建促销码")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: { router.back() }) {
                Label("返回", systemImage: "chevron.left")
                    .foregroundStyle(Color(hex: "#333333"))
            }
        )

        .fileImporter(
            isPresented: $isShowingFilePicker,
            allowedContentTypes: [.commaSeparatedText]
        ) { result in
            switch result {
            case let .success(url):
                do {
                    let content = try String(contentsOf: url)
                    viewModel.processCSVContent(content)
                } catch {
                    notice.openNotice(open: .toast("CSV读取失败"))
                }
            case let .failure(error):
                notice.openNotice(open: .toast("文件选择失败\(error.localizedDescription)"))
            }
        }
    }

    private func removePromoCode(_ code: String) {
        viewModel.promoCodes.removeAll { $0 == code }
    }
}

// 在 CreatePromotionView 结构体内添加这个私有视图组件
private struct ProductSelectItem: View {
    let product: ProductInfo
    let isSelected: Bool

    var body: some View {
        VStack {
            ImgLoader(product.icon)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(product.name)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
}

#Preview("CreatePromotionView_Previews") {
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
        CreatePromotionView()
            .environmentObject(router)
            .environmentObject(noticeManager)
            .environmentObject(sheetManager)
            .environmentObject(productService)
    }
}
