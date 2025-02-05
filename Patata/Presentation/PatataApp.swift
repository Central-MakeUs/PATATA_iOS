//
//  PatataApp.swift
//  Patata
//
//  Created by 김진수 on 1/13/25.
//

import SwiftUI
import GoogleSignIn
import ComposableArchitecture

@main
struct PatataApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(store: Store(initialState: RootCoordinator.State.initialState, reducer: {
                RootCoordinator()
            }))
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
