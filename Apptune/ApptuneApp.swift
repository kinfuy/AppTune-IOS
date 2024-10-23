//
//  SuperIdApp.swift
//  SuperId
//
//  Created by 杨杨杨 on 2024/4/21.
//

import SwiftDate
import SwiftUI

@main
struct ApptuneApp: App {
    
    init() {
        SwiftDate.defaultRegion = Region.local
    }

    var body: some Scene {
        WindowGroup {
            ScreenManage()
        }
    }
}
