//
//  ArchiveView.swift
//  Patata
//
//  Created by 김진수 on 1/28/25.
//

import SwiftUI
import ComposableArchitecture
// 체크가 될때 체크된 스팟들을 담아서 서버에 보내야됨

struct ArchiveView: View {
    
    @Perception.Bindable var store: StoreOf<ArchiveFeature>
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible())
    ]
    
    @State private var chooseIsValid: Bool = false
    @State private var checkSpots: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            contentView
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
            
            // 선택될때마다 배열에 추가를 한다.
            // 근데 또 한 번 선택을 당하면 배열에서 뺀다
            // 추가될때마다 spotId를 추가를 하는데 만약 배열에 같은 spotId가 있다면 배열에서 제거 없다면 배열에 추가
            // 그리고 배열에 추가된 뷰는 테두리가 파란색이다.
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(store.archiveList.enumerated()), id: \.element.spotId) { index, item in
                        archiveItem(item)
                            .overlay(
                                Group {
                                    if chooseIsValid {
                                        Rectangle()
                                            .stroke(store.tappedSpotList.contains(item.spotId) ? Color.blue100 : Color.clear)
                                            .foregroundStyle(.clear)
                                    }
                                }
                            )
                            .asButton {
                                store.send(.viewEvent(.tappedSpot(item.spotId)))
                                if chooseIsValid {
                                    checkSpots.toggle()
                                }
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
                
                Text(chooseIsValid ? "삭제" : "선택")
                    .padding(.trailing, 15)
                    .textStyle(.subtitleM)
                    .foregroundStyle(chooseIsValid ? .blue100 : .textDefault)
                    .asButton {
                        chooseIsValid.toggle()
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
                if chooseIsValid {
                    if !store.tappedSpotList.contains(item.spotId) {
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.gray, lineWidth: 1)
                            )
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 12)
                            .padding(.top, 12)
                            .onTapGesture {
                                checkSpots = true
                            }
                        
                    } else {
                        Image("CircleCheck")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 12)
                            .padding(.top, 12)
                            .onTapGesture {
                                checkSpots = false
                            }
                    }
                }
            }
    }
}
