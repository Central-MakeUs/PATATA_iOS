//
//  MyPageCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct MyPageCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<MyPageCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.routes, action: \.router)) {
                MyPageView(store: store.scope(state: \.root, action: \.root))
            } destination: { store in
                switch store.case {
                case let .setting(settingStore):
                    SettingView(store: settingStore)
                    
                case let .deleteID(deleteIDStore):
                    DeleteIDView(store: deleteIDStore)
                    
                case let .profileEdit(profileStore):
                    ProfileEditView(store: profileStore)
                    
                case let .success(successStore):
                    SuccessView(store: successStore)
                    
                case let .spotDetail(spotDetailStore):
                    SpotDetailView(store: spotDetailStore)
                    
                case let .spotedit(spotEditStore):
                    SpotEditorView(store: spotEditStore)
                    
                case let .addSpotMap(addSpotMapStore):
                    AddSpotMapView(store: addSpotMapStore)
                    
                case let .openSource(openSource):
                    OpenSourceView(store: openSource)
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
