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
            switch store.state {
            case .splash:
                if let store = store.scope(state: \.splash, action: \.splashAction) {
                    SplashView(store: store)
                }
                
            case .onboarding:
                if let store = store.scope(state: \.onboarding, action: \.onboarding) {
                    OnboardingView(store: store)
                }
                
            case .login:
                if let store = store.scope(state: \.login, action: \.login) {
                    LoginView(store: store)
                }
                
            case .tabBar:
                if let store = store.scope(state: \.tabBar, action: \.tabBar) {
                    TabCoordinatorView(store: store)
                }
            }
        }
    }
}

