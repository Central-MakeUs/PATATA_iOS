//
//  PatataApp.swift
//  Patata
//
//  Created by 김진수 on 1/13/25.
//

import SwiftUI
import GoogleSignIn
import ComposableArchitecture
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)  -> Bool {
      FirebaseApp.configure()
    
      return true
    }
}

@main
struct PatataApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(store: Store(initialState: RootCoordinator.State(), reducer: {
                RootCoordinator()
            }))
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
