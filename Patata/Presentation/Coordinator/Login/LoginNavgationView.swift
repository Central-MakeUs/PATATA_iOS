//
//  LoginNavgationView.swift
//  Patata
//
//  Created by 김진수 on 7/29/25.
//

import SwiftUI
import ComposableArchitecture

struct LoginNavigationView: View {
    @Perception.Bindable var store: StoreOf<LoginNavigationFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.routes, action: \.routes)) {
                LoginView(store: store.scope(state: \.root, action: \.root))
            } destination: {
                switch $0.case {
                case let .profileEdit(store):
                    ProfileEditView(store: store)
                    
                case let .success(store):
                    SuccessView(store: store)
                    
                default:
                    EmptyView()
                }
            }
        }
    }
}
