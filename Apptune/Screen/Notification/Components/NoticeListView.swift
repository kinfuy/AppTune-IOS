import SwiftUI

struct NoticeListView: View {
    @EnvironmentObject var router: Router
    @StateObject var viewModel: NoticeViewModel<Notification>
    let title: String

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.notices) { notice in
                        NoticeRow(notice: notice)
                            .onAppear {
                                Task {
                                    await viewModel.markAsRead(notice.id)
                                    if notice.id == viewModel.notices.last?.id {
                                        await viewModel.loadMore()
                                    }
                                }
                            }
                    }

                    if viewModel.notices.isEmpty {
                        EmptyView()
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .refreshable {
                Task {
                    await viewModel.loadMore()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#f4f4f4"))
        .navigationBarBackButtonHidden()
        .navigationBarTitle(title)
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
        .task {
            await viewModel.loadInitial()
        }
    }
}

struct NoticeRow: View {
    let notice: Notification

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                // 未读标记
                if !notice.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }

                Text(notice.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#333333"))

                Spacer()

                Text(notice.createTime.formatted())
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#999999"))
            }

            Text(notice.content)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#666666"))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
