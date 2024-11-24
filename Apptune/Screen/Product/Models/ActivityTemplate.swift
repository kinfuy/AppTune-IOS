import Foundation

struct ActivityTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let duration: Int // 活动持续时间(小时)
    let coverImage: String
    let category: String
    
    // 预设的模板数据
    static let templates: [ActivityTemplate] = [
        ActivityTemplate(
            id: "1",
            name: "新品首发",
            description: "产品新功能发布活动模板",
            duration: 48,
            coverImage: "app",
            category: "产品发布"
        ),
        ActivityTemplate(
            id: "2", 
            name: "限时优惠",
            description: "产品促销优惠活动模板",
            duration: 72,
            coverImage: "app",
            category: "促销活动"
        ),
        ActivityTemplate(
            id: "3",
            name: "用户调研",
            description: "收集用户反馈的活动模板",
            duration: 168,
            coverImage: "app",
            category: "用户调研"
        )
    ]
} 
