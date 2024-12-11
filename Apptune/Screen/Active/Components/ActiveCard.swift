struct ActiveCard: View {
  let title: String
  let description: String
  let startAt: Date
  let endAt: Date?
  let joinCount: Int
  let status: Int
  let cover: String
  let productName: String
  let productLogo: String
  let canOperate: Bool
  let onTap: () -> Void

  var body: some View {
    VStack {
      // 卡片内容...
    }
    .onTapGesture {
      onTap()
    }
  }
}
