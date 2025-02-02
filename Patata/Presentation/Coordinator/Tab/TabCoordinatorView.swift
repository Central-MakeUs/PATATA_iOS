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
                            HomeCoordinatorView(store: store.scope(state: \.homeTabState, action: \.homeTabAction))
                                .tag(TabCase.home)
                        }
                        
                        Tab(
                            "내주변",
                            image: store.tabState == .map ? "SpotActive" : "SpotInActive",
                            value: .map
                        ) {
                            MapCoordinatorView(store: store.scope(state: \.mapTabState, action: \.mapTabAction))
                                .tag(TabCase.map)
                        }
                    }
                    .tint(.textDefault)
                } else {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        HomeCoordinatorView(store: store.scope(state: \.homeTabState, action: \.homeTabAction))
                            .tabItem {
                                Image(store.tabState == .home ? "HomeActive" : "HomeInActive")
                            }
                            .tag(TabCase.home)
                        MapCoordinatorView(store: store.scope(state: \.mapTabState, action: \.mapTabAction))
                            .tabItem {
                                Image(store.tabState == .map ?  "SpotActive" : "SpotInActive")
                            }
                            .tag(TabCase.map)
                    }
                }
            }
        }
    }
}
