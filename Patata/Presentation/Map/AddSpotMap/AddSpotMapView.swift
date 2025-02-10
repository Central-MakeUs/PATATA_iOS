//
//  AddSpotMapView.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import SwiftUI
import ComposableArchitecture

// 스팟 추가하기 일때 유저의 마커를 보여줘야되는지

struct AddSpotMapView: View {
    
    @Perception.Bindable var store: StoreOf<AddSpotMapFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden()
        }
    }
}

extension AddSpotMapView {
    private var contentView: some View {
        VStack(spacing: 0) {
            fakeNavgationBar
                .padding(.horizontal, 15)
                .padding(.bottom, 12)
            
            ZStack(alignment: .bottom) {
                ZStack(alignment: .top) {
                    UIMapView(mapState: store.mapState, locationToAddress:  { lat, long in
                        store.send(.viewEvent(.locationToAddress(lat: lat, long: long)))
                    })
                    .overlay(alignment: .center) {
                        Image("ActivePin")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                            .offset(y: -40)
                    }
                    
                    Color.black
                        .opacity(0.1)
                        .frame(height: 4)
                        .blur(radius: 3)
                }
                
                VStack {
                    addressView
                        .padding(.vertical, 20)
                        .padding(.horizontal, 15)
                }
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
    }
    
    private var fakeNavgationBar: some View {
        ZStack {
            Text("스팟 추가하기")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                NavBackButton {
                    store.send(.viewEvent(.tappedBackButton))
                }
                
                Spacer()
            }
        }
    }
    
    private var addressView: some View {
        VStack(alignment: .center) {
            Text("공유하고 싶은 장소를 선택해주세요!")
                .textStyle(.subtitleM)
                .foregroundStyle(.textDefault)
            
            HStack {
                Text(store.address)
                    .textStyle(.bodyS)
                    .foregroundStyle(.textDisabled)
                    .padding(.leading, 12)
                    .padding(.vertical, 12)
                
                Spacer()
            }
            .background(.gray20)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack {
                Spacer()
                
                Text("선택 완료")
                    .textStyle(.subtitleM)
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                
                Spacer()
            }
            .background(.gray50)
            .clipShape(RoundedRectangle(cornerRadius: 38))
            .asButton {
                store.send(.viewEvent(.tappedAddConfirmButton))
            }
        }
    }
}
