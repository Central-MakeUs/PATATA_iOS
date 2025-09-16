//
//  MapCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct MapCoordinatorView: View {
    // spot이 선택 되어있지 않아야하고 hidden상태도 false여야함
    @Perception.Bindable var store: StoreOf<MapCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.routes, action: \.router)) {
                ZStack(alignment: .bottom) {
                    SpotMapView(store: store.scope(state: \.root, action: \.root))
                    
                    FakeTabView(selectedCase: .map)
                        .opacity((store.isHidden && !store.isPresent) ? 1 : 0)
                        .ignoresSafeArea(edges: .bottom)
                }
            } destination: { otherStore in
                switch otherStore.case {
                case let .mySpotList(mySpotListStore):
                    MySpotListView(store: mySpotListStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
                    
                case let .spotEditorView(spotEditorStore):
                    SpotEditorView(store: spotEditorStore)
                    
                case let .search(searchStore):
                    SearchView(store: searchStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
                    
                case let .searchMap(searchMapStore):
                    SearchMapView(store: searchMapStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
                    
                case let .addSpotMap(addSpotMapStore):
                    AddSpotMapView(store: addSpotMapStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
                    
                case let .successView(successStore):
                    SuccessView(store: successStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
                    
                case let .spotDetail(detailStore):
                    SpotDetailView(store: detailStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
                    
                case let .report(reportStore):
                    ReportView(store: reportStore)
                        .onDisappear {
                            store.send(.viewCycle(.disAppear))
                        }
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
                            .backgroundColor(.gray.opacity(0.2))
                            .dismissCallback {
                                store.send(.viewEvent(.dismissPopup))
                            }
                    })
        }
    }
}
