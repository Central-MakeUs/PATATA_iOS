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
    
    @Environment(\.scenePhase) private var scenePhase

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
                        case let .success(successStore):
                            SuccessView(store: successStore)
                        }
                    }

                case .tab:
                    TabCoordinatorView(store: store.scope(state: \.tabCoordinator, action: \.tabCoordinatorAction))
                }
            }
            .customAlert(
                isPresented: $store.isPresent.sending(\.bindingIsPresent),
                title: AlertMessage.locationPermission.title,
                message: AlertMessage.locationPermission.message,
                cancelText: AlertMessage.locationPermission.cancelTitle,
                confirmText: AlertMessage.locationPermission.actionTitle) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .onAppear {
                store.send(.viewCycle(.onAppear))
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .background:
                    store.send(.appLifecycle(.background))
                case .active:
                    store.send(.appLifecycle(.active))
                case .inactive:
                    store.send(.appLifecycle(.inactive))
                @unknown default:
                    break
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
        case .success:
            return .success
        }
    }

    enum ID: Identifiable {
        case splash
        case onboarding
        case login
        case profileEdit
        case success

        var id: ID {
            return self
        }
    }
}
