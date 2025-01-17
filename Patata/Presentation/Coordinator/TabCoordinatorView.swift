//
//  TabCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import TCACoordinators
import ComposableArchitecture

struct TabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<TabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if #available(iOS 18.0, *) {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        Tab(
                            "홈",
                            image: store.tabState == .home ? "HomeActive" : "HomeInActive",
                            value: .home
                        ) {
                            tabContentView()
                        }
                    }
                    .tint(.textDefault)
                } else {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        tabContentView()
                            .tabItem {
                                Image(store.tabState == .home ? "HomeActive" : "HomeInActive")
                            }
                            .tag(TabCase.home)
                    }
                }
            }
        }
    }
}

extension TabCoordinatorView {
    private func tabContentView() -> some View {
        Group {
            HomeCoordinatorView(store: store.scope(state: \.homeTabState, action: \.homeTabAction))
                .tag(TabCase.home)
        }
    }
}
