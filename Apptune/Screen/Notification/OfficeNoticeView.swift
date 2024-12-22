//
//  OfficeNoticeView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import SwiftUI

struct OfficeNoticeView: View {
  @StateObject private var viewModel: NoticeViewModel<Notification>
  @EnvironmentObject private var notificationService: NotificationService

  init() {
    _viewModel = StateObject(
      wrappedValue: NoticeViewModel(
        type: .official,
        notificationService: NotificationService()
      ))
  }

  var body: some View {
    NoticeListView(viewModel: viewModel, title: "官方消息")
      .onAppear {
        viewModel.updateNotificationService(notificationService)
      }
  }
}
