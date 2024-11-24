import SwiftUI

struct ActivityTemplatesSheet: View {
    @EnvironmentObject var sheet: SheetManager
    var onSelect: ((_ temp: ActivityTemplate) -> Void)?
    var onCancel: (() -> Void)?
    var body: some View {
        VStack {
            // 顶部导航栏
            HStack {
                Text("从模板库新建")
                    .foregroundColor(.black)
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

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                ], spacing: 16) {
                    ForEach(ActivityTemplate.templates) { template in
                        TemplateCard(template: template)
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
}

struct TemplateCard: View {
    let template: ActivityTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 模板封面图
            HStack{
                Spacer()
                ImgLoader(template.coverImage)
                    .frame(width: 120, height: 80)
                    .cornerRadius(12)
                Spacer()
            }
            // 模板信息
            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#333333"))

                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#666666"))
                    .lineLimit(2)

                HStack {
                    Text(template.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)

                    Spacer()

                    Text("\(template.duration)小时")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#999999"))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 8)
    }
}

#Preview {
    Text("test")
        .sheet(isPresented: .constant(true)) {
            ActivityTemplatesSheet()
                .environmentObject(SheetManager())
        }
}
