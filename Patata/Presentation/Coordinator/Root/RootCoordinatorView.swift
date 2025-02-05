//
//  RootCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct RootCoordinatorView: View {

    @Perception.Bindable var store: StoreOf<RootCoordinator>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.viewState {
                case .start:
                    TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                        switch screen.case {
                        case let .splash(store):
                            SplashView(store: store)
                        case let .onboarding(store):
                            OnboardingView(store: store)
                        case let .login(store):
                            LoginView(store: store)
                        case let .profileEdit(store):
                            ProfileEditView(store: store)
                        }
                    }

                case .tab:
                    TabCoordinatorView(store: store.scope(state: \.tabCoordinator, action: \.tabCoordinatorAction))
                }
            }
        }
    }
}

extension RootScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .splash:
            return .splash
        case .onboarding:
            return .onboarding
        case .login:
            return .login
        case .profileEdit:
            return .profileEdit
        }
    }

    enum ID: Identifiable {
        case splash
        case onboarding
        case login
        case profileEdit

        var id: ID {
            return self
        }
    }
}
