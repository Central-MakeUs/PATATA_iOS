//
//  ArchiveCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ArchiveCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<ArchiveCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.routes, action: \.router)) {
                ArchiveView(store: store.scope(state: \.root, action: \.root))
            } destination: { store in
                switch store.case {
                case let .spotDetail(detailStore):
                    SpotDetailView(store: detailStore)
                    
                case let .spotedit(spotEditStore):
                    SpotEditorView(store: spotEditStore)
                    
                case let .addSpotMap(addSpotMapStore):
                    AddSpotMapView(store: addSpotMapStore)
                    
                case let .report(reportStore):
                    ReportView(store: reportStore)
                    
                case let .category(categoryStore):
                    SpotCategoryView(store: categoryStore)
                }
            }
            .customAlert(
                isPresented: $store.alertIsPresent.sending(\.bindingAlertIsPrenset),
                title: "신고가 접수되었습니다",
                message: "24시간 이내에 검토 후 처리될 예정이며,\n신고된 사용자의 댓글 및 스팟 업로드 등의 활동이\n일시적으로 제한되었습니다.",
                onConfirm: {
                    store.send(.viewEvent(.dismissAlert))
                }
            )
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
