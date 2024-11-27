import SwiftUI

struct CoinTaskItem: View {
    let title: String
    let coin: Int
    let icon: String
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.opacity(0.15), Color.theme.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.theme)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))

                    HStack(spacing: 4) {
                        Text("奖励")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(coin)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.theme)
                        Text("积分")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isCompleted {
                    Text("已完成")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                } else {
                    Text("去完成")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color.theme, Color.theme.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct CoinTasksView: View {
    @EnvironmentObject var router: Router
    @StateObject private var viewModel = CoinTasksViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 任务分组
                VStack(spacing: 16) {
                    Text("每日任务")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if viewModel.dailyTasks.isEmpty {
                        EmptyView(text: "敬请期待", image: "nodata", size: 120)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.dailyTasks) { task in
                            CoinTaskItem(
                                title: task.title,
                                coin: task.coin,
                                icon: task.icon,
                                isCompleted: task.isCompleted,
                                action: { viewModel.completeTask(task) }
                            )
                        }
                    }
                }
                .padding()
                .background(
                    ZStack {
                        Color.white
                        // 装饰性渐变
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.opacity(0.1), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150)
                            .blur(radius: 30)
                            .offset(x: -100, y: -50)
                    }
                )
                .cornerRadius(20)

//                VStack(spacing: 16) {
//                    Text("成长任务")
//                        .font(.system(size: 16, weight: .semibold))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    if viewModel.permanentTasks.isEmpty {
//                        EmptyView(text: "敬请期待", image: "nodata", size: 120)
//                    }
//
//                    VStack(spacing: 12) {
//                        ForEach(viewModel.permanentTasks) { task in
//                            CoinTaskItem(
//                                title: task.title,
//                                coin: task.coin,
//                                icon: task.icon,
//                                isCompleted: task.isCompleted,
//                                action: { viewModel.completeTask(task) }
//                            )
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(20)
            }
            .padding()
        }
        .background(Color(hex: "#f4f4f4"))
        .navigationBarBackButtonHidden()
        .navigationBarTitle("积分任务")
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
        .refreshable {
            await viewModel.fetchTasks()
        }
    }
}


#Preview {
    CoinTasksView()
        .environmentObject(Router())
}
