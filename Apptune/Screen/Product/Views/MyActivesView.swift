import SwiftUI

struct MyActivesView: View {
  @EnvironmentObject private var acticeService: ActiveService
  @EnvironmentObject var router: Router

  var isEmpty: Bool {
    acticeService.selfActives.isEmpty
  }

  var body: some View {
    Group {
      if acticeService.selfPage.loading {
        VStack {
          Spacer()
          LoadingComponent()
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVStack(spacing: 16) {
            if isEmpty {
              EmptyView(text: "快新建一个活动吧")
                .padding(.horizontal)
            } else {
              ForEach(acticeService.selfActives, id: \.id) { ac in
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
                .onTapGesture {
                  router.navigate(to: .activeDetail(active: ac))
                }
              }
            }
          }
          .padding(.horizontal)
        }
      }
    }
    .onAppear {
      Task {
        await acticeService.loadSelfActives(refresh: true)
      }
    }
    .customNavigationBar(title: "我的活动", router: router)
  }
}

#Preview("我的活动") {
  MyActivesView()
    .environmentObject(Router())
    .environmentObject(ActiveService())
}
