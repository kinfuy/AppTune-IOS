//
//  UserProfileView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/27.
//

import PhotosUI
import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var userService: UserService
    @State private var selectedItem: PhotosPickerItem?
    @State private var name: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 头像部分
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 12) {
                        ImgLoader(userService.profile.avatar)
                            .frame(width: 100, height: 100)
                            .clipShape(.circle)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)

                        Text("点击更换头像")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            if let url = await uploadImage(image) {
                                await updateUserInfo(["avatar": url])
                            }
                        }
                    }
                }

                // 个人信息表单
                VStack(spacing: 0) {
                    // 昵称
                    FormField(
                        title: "昵称",
                        text: $name,
                        placeholder: "设置你的昵称"
                    )

                    // 邮箱（只读）
                    FormField(
                        title: "邮箱",
                        text: .constant(userService.profile.email),
                        isEditable: false
                    )
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                .padding(.horizontal)

                // 保存按钮
                Button(action: {
                    Task {
                        await saveUserInfo()
                    }
                }) {
                    Text("保存修改")
                        .buttonStyle(.black)
                        .frame(height: 38)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .padding(.vertical)
        }
        .onAppear {
            name = userService.profile.name
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#f4f4f4"))
        .navigationBarBackButtonHidden()
        .navigationBarTitle("编辑资料")
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

    // 上传图片
    private func uploadImage(_ image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
        do {
            let url = try await FileAPI.shared.uploadAvatar(imageData)
            return url
        } catch {
            router.openNotice(open: .toast(.init(msg: "图片上传失败")))
            return nil
        }
    }

    // 更新用户信息
    private func updateUserInfo(_ info: [String: Any]) async {
        do {
            let _ = try await UserAPI.shared.updateUserInfo(info)
            router.openNotice(open: .toast(Toast(msg: "更新成功")))
            router.back()
        } catch {
            router.openNotice(open: .toast(Toast(msg: "更新失败")))
        }
    }

    // 保存用户信息
    private func saveUserInfo() async {
        let info: [String: Any] = [
            "name": name,
        ]
        await updateUserInfo(info)
    }
}

// 表单项组件
struct FormField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isEditable: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 14))

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .disabled(!isEditable)
                .foregroundColor(isEditable ? .black : .gray)
        }
        .padding()
        .background(Color.white)

        Divider()
            .padding(.horizontal)
    }
}

#Preview {
    UserProfileView()
        .environmentObject(Router())
        .environmentObject(UserService())
}
