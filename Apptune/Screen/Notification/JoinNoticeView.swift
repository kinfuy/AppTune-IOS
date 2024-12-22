//
//  JoinNoticeView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import SwiftUI

struct JoinNoticeView: View {
  @StateObject private var viewModel: NoticeViewModel<Notification>
  @EnvironmentObject private var notificationService: NotificationService

  init() {
    _viewModel = StateObject(
      wrappedValue: NoticeViewModel(
        type: .join,
        notificationService: NotificationService()
      ))
  }

  var body: some View {
    NoticeListView(viewModel: viewModel, title: "报名消息")
      .onAppear {
        viewModel.updateNotificationService(notificationService)
      }
  }
}
