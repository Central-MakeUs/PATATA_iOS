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
