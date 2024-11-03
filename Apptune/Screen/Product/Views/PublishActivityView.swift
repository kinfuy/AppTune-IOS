import SwiftUI

struct PublishActivityView: View {
  @StateObject private var viewModel = PublishActivityViewModel()
  @EnvironmentObject private var router: Router

  var body: some View {
      Form {
        Section("活动信息") {
          TextField("活动名称", text: $viewModel.activityName)
          TextField("活动描述", text: $viewModel.activityDescription)
          DatePicker("开始时间", selection: $viewModel.startTime)
          DatePicker("结束时间", selection: $viewModel.endTime)
        }

        Button("发布") {
          Task {
            try await viewModel.publishActivity()
          }
        }
      }
      .background(Color(hex: "#f4f4f4"))
      .navigationBarBackButtonHidden()
      .navigationBarTitle("发布活动")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(
        leading: Button(
          action: {
            router.back()
          },
          label: {
            Group {
              HStack {
                SFSymbol.back
              }
            }
            .foregroundStyle(Color(hex: "#333333"))
          })
      )
  }
}
