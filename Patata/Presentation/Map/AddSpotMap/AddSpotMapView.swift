//
//  AddSpotMapView.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

// 스팟 추가하기 일때 유저의 마커를 보여줘야되는지

struct AddSpotMapView: View {
    
    @Perception.Bindable var store: StoreOf<AddSpotMapFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden()
                .popup(isPresented: $store.isPresent.sending(\.bindingIsPresent), view: {
                    HStack {
                        Spacer()
                        
                        Text("반경 100m 내에 등록된 장소가 많아 장소를 등록할 수 없어요")
                            .textStyle(.subtitleXS)
                            .foregroundStyle(.blue20)
                            .padding(.vertical, 10)
                        
                        Image("NoAddIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        
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
                        .backgroundColor(.black.opacity(0.2))
                        .dismissCallback {
                            store.send(.viewEvent(.dismissPopup))
                        }
                    
                })
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension AddSpotMapView {
    private var contentView: some View {
        VStack(spacing: 0) {
            fakeNavgationBar
                .padding(.horizontal, 15)
                .padding(.bottom, 14)
            
            ZStack(alignment: .bottom) {
                ZStack(alignment: .top) {
                    UIMapView(mapManager: store.mapManager)
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
            .background(store.addValid ? .navy100 : .gray50)
            .clipShape(RoundedRectangle(cornerRadius: 38))
            .asButton {
                if store.addValid {
                    store.send(.viewEvent(.tappedAddConfirmButton))
                }
            }
        }
    }
}
