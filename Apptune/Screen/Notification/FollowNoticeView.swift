//
//  FollowNoticeView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import SwiftUI

struct FollowNoticeView: View {
  @StateObject private var viewModel: NoticeViewModel<Notification>
  @EnvironmentObject private var notificationService: NotificationService

  init() {
    _viewModel = StateObject(
      wrappedValue: NoticeViewModel(
        type: .follow,
        notificationService: NotificationService()
      ))
  }

  var body: some View {
    NoticeListView(viewModel: viewModel, title: "关注消息")
      .onAppear {
        viewModel.updateNotificationService(notificationService)
      }
  }
}
