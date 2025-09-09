//
//  TabCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

struct TabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<TabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                switch store.tabState {
                case .home:
                    HomeCoordinatorView(store: store.scope(state: \.home, action: \.home))
                    
                case .map:
                    MapCoordinatorView(store: store.scope(state: \.map, action: \.map))
                    
                case .archive:
                    ArchiveCoordinatorView(store: store.scope(state: \.archive, action: \.archive))
                    
                case .myPage:
                    MyPageCoordinatorView(store: store.scope(state: \.myPage, action: \.myPage))
                }
                
                CustomTabView(selectedCase: $store.tabState.sending(\.bindingTab))
                    .ignoresSafeArea(edges: .bottom)
                    .opacity(store.isHidden ? 0 : 1)
            }
            .tint(.textDefault)
        }
    }
}
