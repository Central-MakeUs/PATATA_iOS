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
//            TabCoordinatorView(store: Store(initialState: TabCoordinator.State(tabState: .home), reducer: {
//                TabCoordinator()
//            }))
            
            
//            SpotMapView(store: Store(initialState: SpotMapFeature.State(), reducer: {
//                SpotMapFeature()
//            }))
//            TestView()
//            SpotCategoryView(store: Store(initialState: SpotCategoryFeature.State(), reducer: {
//                SpotCategoryFeature()
//            }))
//            TestView()
//            RootCoordinatorView(store: Store(initialState: RootCoordinator.State.initialState, reducer: {
//                RootCoordinator()
//            }))
//            OnboardingView(store: Store(initialState: OnboardPageFeature.State(), reducer: {
//                OnboardPageFeature()
//            }))
//            LoginView()
//                .onOpenURL { url in
//                    GIDSignIn.sharedInstance.handle(url)
//                }
            LoginView(store: Store(initialState: LoginFeature.State(), reducer: {
                LoginFeature()
            }))
        }
    }
}
