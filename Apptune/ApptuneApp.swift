//
//  ApptuneApp.swift
//  Apptune
//
//  Created by 杨杨杨 on 2024/10/5.
//

import SwiftUI

@main
struct ApptuneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
