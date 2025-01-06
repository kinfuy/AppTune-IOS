import Foundation

// 圈子模型
struct CommunityCircle: Codable {
  let id: String
  let name: String
  let icon: String
}

// 帖子数据模型
struct Post: Identifiable, Codable {
  var id: String = UUID().uuidString
  let title: String  // 帖子标题
  let author: String  // 作者
  let avatar: String  // 作者头像
  let updateTime: Date  // 发布时间
  let images: [String]  // 图片
  let content: String  // 内容
  let link: PostLink?  // 链接
  let helpful: Int  // 有用
  let notHelpful: Int  // 无用
  let userId:String?

  // 当前用户是否点赞
  let isHelpful: Int?  // 0 是未评价, 1 是没用, 2 是有用
}

// 链接预览模型
struct PostLink: Codable {
  let title: String  // 链接标题
  let description: String  // 链接描述
  let thumbnail: String  // 缩略图
  let url: String  // 链接地址
}
