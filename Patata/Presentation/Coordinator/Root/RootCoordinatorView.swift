//
//  RootCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import SwiftUI
import ComposableArchitecture

struct RootCoordinatorView: View {
    @Perception.Bindable var store: StoreOf<RootCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.rootPath {
                case .splash:
                    if let store = store.scope(state: \.rootPath.splash, action: \.rootPath.splash) {
                        SplashView(store: store)
                    }
                    
                case .onboarding:
                    if let store = store.scope(state: \.rootPath.onboarding, action: \.rootPath.onboarding) {
                        OnboardingView(store: store)
                    }
                    
                case .login:
                    if let store = store.scope(state: \.rootPath.login, action: \.rootPath.login) {
                        LoginNavigationView(store: store)
                    }
                    
                case .tabBar:
                    if let store = store.scope(state: \.rootPath.tabBar, action: \.rootPath.tabBar) {
                        TabCoordinatorView(store: store)
                    }
                }
            }
            .onAppear {
                store.send(.viewCycle(.onAppear))
            }
        }
    }
}

