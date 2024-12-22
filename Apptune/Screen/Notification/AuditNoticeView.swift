//
//  AuditNoticeView.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/12/22.
//

import SwiftUI

struct AuditNoticeView: View {
  @StateObject private var viewModel: NoticeViewModel<Notification>
  @EnvironmentObject private var notificationService: NotificationService

  init() {
    _viewModel = StateObject(
      wrappedValue: NoticeViewModel(
        type: .audit,
        notificationService: NotificationService()
      ))
  }

  var body: some View {
    NoticeListView(viewModel: viewModel, title: "审核消息")
      .onAppear {
        viewModel.updateNotificationService(notificationService)
      }
  }
}
