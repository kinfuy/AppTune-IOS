//
//  Tag+Service.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/11/24.
//

import SwiftUI

class TagService: ObservableObject {
    @Published var tags: [Tag] = []
    
    // MARK: - CRUD 操作
    
    /// 获取所有标签
    func fetchAll() {
        // 从本地存储加载标签
        if let data = UserDefaults.standard.data(forKey: "tags"),
           let decodedTags = try? JSONDecoder().decode([Tag].self, from: data) {
            self.tags = decodedTags
        }
    }
    
    /// 添加新标签
    func add(tag: Tag) {
        tags.append(tag)
        saveTags()
    }
    
    /// 删除标签
    func delete(id: UUID) {
        tags.removeAll { $0.id == id }
        saveTags()
    }
    
    /// 更新标签
    func update(tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }
    
    /// 检查标签名是否存在
    func isExitName(name: String) -> Tag? {
        return tags.first { $0.name == name }
    }
    
    // MARK: - 私有方法
    
    /// 保存标签到本地存储
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: "tags")
        }
    }
}

