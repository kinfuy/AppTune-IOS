import Foundation

@MainActor
class NoticeViewModel<T: Identifiable & Decodable>: ObservableObject {
    @Published var notices: [T] = []
    @Published var hasMore = true
    @Published var isLoading = false

    private var totalNotices: Int = 0
    private var page = 1
    private let pageSize = 20
    private let type: NotificationType
    private var notificationService: NotificationService

    private var hasMoreNotices: Bool {
        totalNotices == 0 || notices.count < totalNotices
    }

    init(type: NotificationType, notificationService: NotificationService) {
        self.type = type
        self.notificationService = notificationService
    }

    func loadInitial() async {
        page = 1
        notices = []
        totalNotices = 0
        hasMore = true
        await loadMore()
    }

    func loadMore() async {
        guard (totalNotices == 0 || hasMoreNotices) && !isLoading else { return }

        isLoading = true
        do {
            let params = QueryMessageParams(type: type, page: page, pageSize: pageSize)
            let response = try await API.fetchMessages(params: params)
            if let typedNotices = response.items as? [T] {
                notices.append(contentsOf: typedNotices)
                totalNotices = response.total
                hasMore = hasMoreNotices
                page += 1
            }
        } catch {
            print("加载通知失败：\(error)")
        }
        isLoading = false
    }

    func markAsRead(_ id: String) async {
        do {
            try await API.markMessageAsRead(id: id)
            await notificationService.fetchUnreadCount()
        } catch {
            print("标记已读失败：\(error)")
        }
    }

    func updateNotificationService(_ service: NotificationService) {
        notificationService = service
    }

    func delete(_ id: String) async {
        do {
            try await API.deleteMessage(id: id)
            await loadInitial()
        } catch {
            print("删除通知失败：\(error)")
        }
    }

    func deleteAllMessages() async {
        do {
            try await API.deleteAllMessages(type: type)
            await loadInitial()
        } catch {
            print("删除所有消息失败：\(error)")
        }
    }
}
