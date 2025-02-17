//
//  MyPageCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct MyPageCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<MyPageCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .myPage(myPageStore):
                    MyPageView(store: myPageStore)
                }
            }
        }
    }
}

extension MyPageScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .myPage:
            return ID.myPage
        }
    }
    
    enum ID: Identifiable {
        case myPage
        
        var id: ID {
            return self
        }
    }
}

