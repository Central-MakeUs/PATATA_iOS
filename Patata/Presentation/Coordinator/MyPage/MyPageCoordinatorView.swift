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
                        .hideTabBar(store.isHideTabBar)
                    
                case let .setting(settingStore):
                    SettingView(store: settingStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .deleteID(deleteIDStore):
                    DeleteIDView(store: deleteIDStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .profileEdit(profileStore):
                    ProfileEditView(store: profileStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .success(successStore):
                    SuccessView(store: successStore)
                        .hideTabBar(store.isHideTabBar)
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
        case .setting:
            return ID.setting
        case .deleteID:
            return ID.deleteID
        case .profileEdit:
            return ID.profileEdit
        case .success:
            return ID.success
        }
    }
    
    enum ID: Identifiable {
        case myPage
        case setting
        case deleteID
        case profileEdit
        case success
        
        var id: ID {
            return self
        }
    }
}

