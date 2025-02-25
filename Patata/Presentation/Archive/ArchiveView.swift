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
        VStack(spacing: 0) {
            
            if store.archiveList.isEmpty {
                fakeNavBar
                    .padding(.top, 4)
                    .padding(.bottom, 14)
                
                Spacer()
                
                searchFailView
                
                Spacer()
            } else {
                
                fakeNavBar
                    .padding(.top, 4)
                    .padding(.bottom, 14)
                
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
                    .padding(.top, 4)
                    .background(.white)
                }
            }
        }
        .background(store.archiveList.isEmpty ? .gray20 : .white)
    }
}

extension ArchiveView {
    private var fakeNavBar: some View {
        // 아래로 위치 변경
        ZStack {
            if !store.archiveList.isEmpty {
                Text("아카이브")
                    .textStyle(.subtitleM)
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
            } else {
                HStack {
                    Spacer()
                    
                    Text("아카이브")
                        .textStyle(.subtitleL)
                        .foregroundStyle(.textDefault)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var searchFailView: some View {
        VStack {
            Image("SearchFail")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130, height: 150)
            
            VStack(alignment: .center) {
                Text("아직 아카이빙한 스팟이 없어요!")
            }
            .textStyle(.subtitleM)
            .foregroundStyle(.textDisabled)
            
            HStack {
                Spacer()
                
                Text("스팟 둘러보러 가기")
                    .textStyle(.subtitleM)
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                
                Spacer()
            }
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.bottom, 20)
            .padding(.top, 8)
            .padding(.horizontal, 75)
            .asButton {
                store.send(.viewEvent(.tappedConfirmButton))
            }
        }
    }
}

extension ArchiveView {
    private func archiveItem(_ item: ArchiveListEntity) -> some View {
        DownImageView(url: item.representativeImageUrl, option: .max, fallBackImg: "ImageDefault")
            .aspectRatio(1, contentMode: .fit)
            .clipped()
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
