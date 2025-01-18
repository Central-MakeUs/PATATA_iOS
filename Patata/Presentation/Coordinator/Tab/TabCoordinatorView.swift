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
                customTabView(
                    selection: $store.tabState.sending(\.bindingTab),
                    tabState: store.tabState,
                    tabContentView: tabContentView
                )
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
