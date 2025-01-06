import PhotosUI
import SwiftUI

struct CreatePostView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var communityService: CommunityService
  @EnvironmentObject var notice: NoticeManager
  @EnvironmentObject var sheet: SheetManager

  @State private var content: String = ""
  @State private var selectedImages: [String] = []
  @State private var selectedCircle: CommunityCircle? = nil
  @State private var selectedLink: PostLink?
  // 最大字数限制
  private let maxCharacterCount = 500

  // 上传图片
  private func uploadImage(_ image: UIImage) async -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
    do {
      let url = try await API.uploadAvatar(imageData)
      return url
    } catch {
      notice.open(open: .toast("图片上传失败"))
      return nil
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {

        CustomTextField(
          text: $content,
          placeholder: "和伙伴们分享一些有趣的经验吧...",
          isMultiline: true,
          height: 300,
          verticalPadding: 12,
          horizontalPadding: 16,
          maxLength: maxCharacterCount,
          hideCount: true
        )
        .background(.white)
        .padding(.vertical, 12)
        .cornerRadius(all: 24)

        // 已选择的图片预览
        if !selectedImages.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(selectedImages, id: \.self) { image in
                ImgLoader(image)
                  .frame(width: 80, height: 80)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
                  .overlay(
                    Button(action: {
                      selectedImages.removeAll { $0 == image }
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

        if let link = selectedLink {
          LinkPreview(link: link)
        }
      }
      .padding()
    }
    .customNavigationBar(title: "经验分享", router: router)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("发布") {
          Task {
            let post = CreatePostDTO(
              title: "",
              content: content,
              images: selectedImages,
              link: selectedLink
            )
            await communityService.createPost(
              post,
              success: {
                Task {
                  await communityService.loadPendingPostReviews()
                  router.back()
                }
              })
          }
        }
        .disabled(content.isEmpty || content.count > maxCharacterCount)
      }
    }

    // 底部工具栏
    .safeAreaInset(edge: .bottom) {
      VStack {
        HStack(spacing: 20) {
          Button(action: {
            sheet.show(
              .imagePicker(onSelect: { image in
                Task {
                  if let url = await uploadImage(image) {
                    selectedImages.append(url)
                  }
                }
              }))
          }) {
            Image(systemName: "photo")
              .foregroundColor(.gray)
          }

          Button(action: {
            sheet.show(
              .linkPicker(onConfirm: { link in
                selectedLink = link
              })
            )
          }) {
            Image(systemName: "link")
              .foregroundColor(.gray)
          }

          Spacer()

          // 字数显示
          Text("\(content.count)/\(maxCharacterCount)")
            .font(.caption)
            .foregroundColor(content.count > maxCharacterCount ? .red : .gray)
        }
        .padding()
        .background(Color(.systemBackground))
      }
    }
  }
}

#Preview {
  NavigationStack {
    CreatePostView()
      .environmentObject(Router())
  }
}
