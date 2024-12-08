import SwiftUI

struct ActivityTemplatesSheet: View {
  @EnvironmentObject var sheet: SheetManager
  @StateObject private var activeService = ActiveService.shared

  var onSelect: ((_ temp: ActiveTemplateInfo) -> Void)?
  var onCancel: (() -> Void)?

  var body: some View {
    VStack {
      // 顶部导航栏
      HStack {
        Text("从模板库新建")
          .foregroundColor(.black)
          .font(.system(size: 16, weight: .medium))
        Spacer()
        SFSymbol.close
          .onTapGesture {
            if let cancel = onCancel {
              cancel()
            }
            sheet.close()
          }
          .foregroundColor(.gray)
      }
      .padding(.horizontal)
      .padding(.top, 16)
      .padding(.bottom, 16)

      if activeService.isTemplatesLoading {
        ProgressView()
          .progressViewStyle(.circular)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if activeService.templates.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "doc.text.magnifyingglass")
            .font(.system(size: 48))
            .foregroundColor(.gray)
          Text("暂无模板")
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVGrid(
            columns: [GridItem(.flexible())],
            spacing: 16
          ) {
            ForEach(activeService.templates) { template in
              ActiveTemplateCard(template: template)
                .onTapGesture {
                  Tap.shared.play(.light)
                  if let onSelect = onSelect {
                    onSelect(template)
                  }
                  sheet.close()
                }
            }
          }
          .padding()
        }
      }
    }
    .task {
      await activeService.loadTemplates()
    }
  }
}

// 模板卡片组件
struct ActiveTemplateCard: View {
  let template: ActiveTemplateInfo

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 封面图
      if let cover = template.cover {
        ImgLoader(cover)
          .frame(height: 160)
          .clipped()
          .cornerRadius(8)
      }

      // 标题
      Text(template.title)
        .font(.system(size: 16, weight: .medium))
        .lineLimit(1)

      // 描述
      if let description = template.description {
        Text(description)
          .font(.system(size: 14))
          .foregroundColor(.gray)
          .lineLimit(2)
      }

      // 添加标签显示
        if template.tags.count > 0 {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(template.tags, id: \.name) { tag in
              Text(tag.name)
                .font(.system(size: 12))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tag.color)
                .foregroundColor(.white)
                .cornerRadius(4)
            }
          }
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
  }
}

#Preview {
  Text("test")
    .sheet(isPresented: .constant(true)) {
      ActivityTemplatesSheet()
        .environmentObject(SheetManager())
    }
}
