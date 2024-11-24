//
//  TagPicker.swift
//  SuKa
//
//  Created by 杨杨杨 on 2024/11/18.
//

import SwiftUI

// 修改 Tag 结构体，添加默认初始化方法
struct Tag: Identifiable, Codable {
    var id: UUID
    var name: String
    var color: Color
    var createAt: Date
    
    init(id: UUID = UUID(), name: String = "", color: Color = .theme, createAt: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.createAt = createAt
    }
}


struct TagEditView: View {
    @Binding var tag: Tag
    var onSave: () -> Void
    var onClose: (() -> Void)?
    
    @State private var customColor: Color = .theme
    @State private var showColorPicker = false
    
    // 预定义一些常用颜色供选择
    let colors: [Color] = [
        .theme,
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple,
        .pink
    ]
    
    var body: some View {
        VStack {
            // 关闭按钮
            if onClose != nil {
                HStack {
                    Spacer()
                    SFSymbol.close
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(8)
                        .background(.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .onTapGesture {
                    onClose!()
                }
            }
            
            // 添加标签预览效果
            HStack {
                Text(tag.name.isEmpty ? "预览" : tag.name)
                    .foregroundColor(tag.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(tag.color.opacity(0.1))
                    )
            }
            .padding(.top, 16)
            
            // 标签名称输入
            HStack {
                TextField("", text: self.$tag.name, prompt: Text("标签名称"))
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
                    .background(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 16)
            .padding(.horizontal)
            
            // 颜色选择器
            VStack(alignment: .leading) {
                Text("选择颜色")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                    .padding(.horizontal)
                    .padding(.top)
                
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 36, maximum: 36))
                ], spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Group {
                                    if tag.color == color {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .padding(2)
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                }
                            )
                            .onTapGesture {
                                tag.color = color
                            }
                    }
                    
                    // 优化自定义颜色选择器
                    ColorPicker("", selection: $tag.color)
                        .labelsHidden()
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if !colors.contains(tag.color) {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .padding(2)
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .bold))
                                }
                            }
                        )
                        .background(
                            Circle()
                                .fill(tag.color)
                        )
                        .clipShape(Circle())
                }
                .padding()
            }
            
            Spacer()
            
            // 保存按钮
            Text("保存")
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#333333"))
                .cornerRadius(16)
                .foregroundColor(.white)
                .padding()
                .onTapGesture {
                    onSave()
                }
        }
        .frame(maxHeight: .infinity)
        .background(.gray.opacity(0.1))
    }
}

struct TagSelectView: View {
    @EnvironmentObject var notice: NoticeManager
    @EnvironmentObject var tagService: TagService
    var onTap: ((_ status: Tag) -> Void)?
    var onClose: (() -> Void)?
    
    @State private var isEdit = false
    @State private var newStatus: Tag = Tag(id: UUID(), name: "", color: .theme, createAt: Date())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if onClose != nil {
                HStack {
                    Spacer()
                    SFSymbol.close
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(8)
                        .background(.gray.opacity(0.2))
                        .clipShape( /*@START_MENU_TOKEN@*/Circle() /*@END_MENU_TOKEN@*/)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .onTapGesture {
                    onClose!()
                }
            }
            
           
            
            if tagService.tags.isEmpty {
                HStack{
                    Spacer()
                    EmptyView(text: "暂无标签", size: 140)
                    Spacer()
                }
                Spacer()
            } else {
                // 标签列表
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(tagService.tags, id: \.id) { tag in
                            HStack(spacing: 12) {
                                // 标签内容
                                HStack(spacing: 6) {
                                    
                                    Text(tag.name)
                                        .foregroundColor(tag.color)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(tag.color.opacity(0.08))
                                )
                                
                                Spacer()
                                
                                // 优化删除按钮
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        tagService.delete(id: tag.id)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.8))
                                        .font(.system(size: 20))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .opacity(0.8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                            )
                            .onTapGesture {
                                if let onTap = onTap {
                                    withAnimation(.spring(response: 0.3)) {
                                        onTap(tag)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            
            HStack{
                Spacer()
                // 新建标签按钮
                Button(action: { isEdit = true }) {
                    HStack {
                        SFSymbol.add
                        Text("新建标签")
                    }
                    .foregroundColor(.theme)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                Spacer()
            }
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $isEdit, content: {
            TagEditView(tag: $newStatus, onSave: {
                if tagService.isExitName(name: newStatus.name) != nil {
                    notice.openNotice(open: .toast(Toast(msg: "标签已存在!")))
                } else {
                    tagService.add(tag: newStatus)
                    isEdit = false
                    newStatus = Tag(id: UUID(), name: "", color: .theme, createAt: Date())
                }
            }, onClose: {
                isEdit = false
            })
            .presentationDetents([.fraction(0.68)])
        })
    }
}

struct TagPicker: View {
    @EnvironmentObject var tagService: TagService
    @Binding var tag: Tag
    @State private var sheet: Bool = false
    var theme:Color = .theme

    var isExist: Bool {
        return tagService.tags.contains(where: {$0.name == tag.name})
    }
    
    var body: some View {
        HStack {
            if tag.name == "" {
                Text("# 添加标签".t())
                    .font(.system(size: 12))
                    .foregroundColor(theme)
            } else {
                Text(tag.name)
                    .foregroundColor(tag.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(tag.color.opacity(0.1))
                    )
            }
        }
        .padding(4)
        .background(theme.opacity(0.1))
        .onTapGesture {
            sheet.toggle()
            Task {
                tagService.fetchAll()
            }
        }
        .sheet(isPresented: $sheet, content: {
            TagSelectView(onTap: {
                tag = $0
                sheet = false
            }, onClose: {
                sheet = false
            })
            .environmentObject(tagService)
            .presentationDetents([.fraction(0.68)])
        })
    }
}

#Preview {
    TagPicker(tag: .constant(Tag()))
        .environmentObject(NoticeManager())
        .environmentObject(TagService())
}
