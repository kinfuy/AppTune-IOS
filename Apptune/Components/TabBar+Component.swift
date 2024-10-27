//
//  ContentView.swift
//  CustomTabbarSwiftUI
//
//  Created by Zeeshan Suleman on 03/03/2023.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case product = 1
    case person = 3
    
    
    static func isWhiteListTabbar(to: TabbedItems) -> Bool {
        let authRoutes: [TabbedItems] = [.home, .product]
        return authRoutes.contains(where: { $0 == to })
    }

    var title: String {
        switch self {
        case .home:
            return "活动"
        case .product:
            return "产品"
        case .person:
            return "我的"
        }
    }

    var iconName: SFSymbol {
        switch self {
        case .home:
            return SFSymbol.card
        case .product:
            return SFSymbol.folder
        case .person:
            return SFSymbol.person
        }
    }
}

struct MainTabbedView: View {
    @EnvironmentObject var router:Router

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $router.currentTab) {
                ActiveHomeView()
                    .tag(TabbedItems.home)
                ProductView()
                    .tag(TabbedItems.product)
                UserView()
                    .tag(TabbedItems.person)
            }

            ZStack {
                HStack {
                    ForEach(TabbedItems.allCases, id: \.self) { item in
                        Button {
                            router.currentTab = item
                        } label: {
                            CustomTabItem(
                                imageName: item.iconName, title: item.title,
                                isActive: router.currentTab == item)
                        }
                    }
                }
                .padding()
            }
            .frame(height: 70)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(35)
            .padding(.horizontal)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

extension MainTabbedView {
    func CustomTabItem(imageName: SFSymbol, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            imageName
                .resizable()
                .renderingMode(.template)
                .fontWeight(isActive ? .heavy : .medium)
                .foregroundColor(isActive ? Color(hex: "#666666") : .gray)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(isActive ? .heavy : .medium)
                    .foregroundColor(isActive ? Color(hex: "#666666") : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? nil : 100)
        .frame(height: 54)
        .background(isActive ? Color.gray.opacity(0.28) : .clear)
        .cornerRadius(30)
    }
}
