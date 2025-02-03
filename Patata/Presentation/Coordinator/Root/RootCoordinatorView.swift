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
                        case let .splash(_):
                            SplashView()
                        case let .onboardPage(_):
                            OnboardingView()
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
        case .onboardPage:
            return .onboardPage
        }
    }

    enum ID: Identifiable {
        case splash
        case onboardPage

        var id: ID {
            return self
        }
    }
}
