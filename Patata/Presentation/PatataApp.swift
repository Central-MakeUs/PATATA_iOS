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
            PatataMainView(store: Store(initialState: PatataMainFeature.State(), reducer: {
                PatataMainFeature()
            }))
//            TabCoordinatorView(store: Store(initialState: TabCoordinator.State(), reducer: {
//                TabCoordinator()
//            }))//                .onOpenURL { url in
//                    GIDSignIn.sharedInstance.handle(url)
//                }
        }
    }
}
