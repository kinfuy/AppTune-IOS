import SwiftUI

struct JoinedActiveView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject private var acticeService: ActiveService

  var isEmpty: Bool {
    acticeService.joinedActives.isEmpty
  }

  var body: some View {
    Group {
      if acticeService.joinedPage.loading {
        VStack {
          Spacer()
          LoadingComponent()
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          if isEmpty {
            EmptyView(text: "你还没有参加任何活动")
              .padding(.horizontal)
          } else {
            ForEach(acticeService.joinedActives) { ac in
              ActiveCard(
                title: ac.title,
                description: ac.description,
                startAt: ac.startAt,
                endAt: ac.endAt,
                joinCount: ac.joinCount ?? 0,
                status: ac.status,
                cover: ac.cover,
                productName: ac.productName,
                productLogo: ac.productLogo
              )
              .contentShape(Rectangle())
              .onTapGesture {
                router.navigate(to: .activeDetail(active: ac))
              }
            }
            .padding(.horizontal)
          }

        }
      }
    }
    .customNavigationBar(title: "参与的活动", router: router)
    .onAppear {
      Task {
        await acticeService.loadJoinedActives()
      }
    }
  }
}

#Preview("参与的活动") {
  JoinedActiveView()
    .environmentObject(Router())
    .environmentObject(ActiveService())
}
