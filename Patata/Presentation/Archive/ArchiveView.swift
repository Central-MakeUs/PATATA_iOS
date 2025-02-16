//
//  ArchiveView.swift
//  Patata
//
//  Created by 김진수 on 1/28/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView
// 체크가 될때 체크된 스팟들을 담아서 서버에 보내야됨

struct ArchiveView: View {
    
    @Perception.Bindable var store: StoreOf<ArchiveFeature>
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible())
    ]
    
    @State private var checkSpots: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .popup(isPresented: $store.popupIsPresent.sending(\.bindingPopupIsPresent), view: {
                    HStack {
                        Spacer()
                        
                        Text(store.deleteText)
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
                        .backgroundColor(.black.opacity(0.5))
                        .dismissCallback {
                            store.send(.viewEvent(.dismissPopup))
                        }
                    
                })
                .customAlert(isPresented: $store.isPresent.sending(\.bindingIsPresent), message: "\(store.selectedSpotList.count)개의 항목을 목록에서\n삭제하시겠습니까?", cancelText: "취소", confirmText: "삭제", onCancle: {
                    print("dismiss")
                    store.send(.viewEvent(.dismissAlert))
                }, onConfirm: {
                    store.send(.viewEvent(.tappedDeleteButton))
                })
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension ArchiveView {
    private var contentView: some View {
        VStack {
            fakeNavBar
            
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(store.archiveList.enumerated()), id: \.element.spotId) { index, item in
                        archiveItem(item)
                            .overlay(
                                Group {
                                    if store.chooseIsValid {
                                        Rectangle()
                                            .stroke(store.selectedSpotList.contains(item.spotId) ? Color.blue100 : Color.clear)
                                            .foregroundStyle(.clear)
                                    }
                                }
                            )
                            .asButton {
                                store.send(.viewEvent(.tappedSpot(item.spotId)))
                            }
                    }
                }
                .background(.white)
                .padding(.top, 4)
            }
        }
    }
}

extension ArchiveView {
    private var fakeNavBar: some View {
        ZStack {
            Text("아카이브")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                Spacer()
                
                Text(store.chooseIsValid ? "삭제" : "선택")
                    .padding(.trailing, 15)
                    .textStyle(.subtitleM)
                    .foregroundStyle(store.chooseIsValid ? .blue100 : .textDefault)
                    .asButton {
                        store.send(.viewEvent(.tappedChoseButton))
                    }
            }
        }
    }
}

extension ArchiveView {
    private func archiveItem(_ item: ArchiveListEntity) -> some View {
        DownImageView(url: item.representativeImageUrl, option: .max, fallBackImg: "ImageDefault")
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                if store.chooseIsValid {
                    if !store.selectedSpotList.contains(item.spotId) {
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.gray, lineWidth: 1)
                            )
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 12)
                            .padding(.top, 12)
                    } else {
                        Image("CircleCheck")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 12)
                            .padding(.top, 12)
                    }
                }
            }
    }
}
