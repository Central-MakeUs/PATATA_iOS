//
//  MyPageCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import PopupView

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
                    
                case let .spotDetail(spotDetailStore):
                    SpotDetailView(store: spotDetailStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .spotedit(spotEditStore):
                    SpotEditorView(store: spotEditStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .addSpotMap(addSpotMapStore):
                    AddSpotMapView(store: addSpotMapStore)
                        .hideTabBar(store.isHideTabBar)
                    
                }
            }
            .popup(isPresented: $store.popupIsPresent.sending(\.bindingPopupIsPresent), view: {
                HStack {
                    Spacer()
                    
                    Text(store.errorMSG)
                        .textStyle(.subtitleXS)
                        .foregroundStyle(.blue20)
                        .padding(.vertical, 10)
                    
                    Spacer()
                }
                .background(.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal, 15)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        store.send(.viewEvent(.dismissPopup))
                    }
                }
            }, customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
                    .closeOnTap(true)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.5))
                    .dismissCallback {
                        store.send(.viewEvent(.dismissPopup))
                    }
            })
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
        case .spotDetail:
            return ID.spotDetail
        case .spotedit:
            return ID.spotedit
        case .addSpotMap:
            return ID.addSpotMap
        }
    }
    
    enum ID: Identifiable {
        case myPage
        case setting
        case deleteID
        case profileEdit
        case success
        case spotDetail
        case spotedit
        case addSpotMap
        
        var id: ID {
            return self
        }
    }
}

