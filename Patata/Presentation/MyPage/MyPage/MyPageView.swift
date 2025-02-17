//
//  MyPageView.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import SwiftUI
import ComposableArchitecture

struct MyPageView: View {
    @Perception.Bindable var store: StoreOf<MyPageFeature>
    
    private let imageCount: Int = 0
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension MyPageView {
    private var contentView: some View {
        VStack(spacing: 0) {
            fakeNavgationBar
                .padding(.bottom, 4)
                
            if store.spotCount == 0 {
                noArchiveView
            } else {
                ArchiveView
            }
        }
    }
    
    private var fakeNavgationBar: some View {
        ZStack {
            Text("내 정보")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                Spacer()
                
                Image("SettingActive")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 15)
                    .asButton {
                        store.send(.viewEvent(.tappedSetting))
                    }
            }
        }
    }
    
    private var noArchiveView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 4)
                .foregroundStyle(.gray20)
            
            VStack(spacing: 0) {
                myProfileView
                    .padding(.top, 40)
                
                archiveSpotBar
                    .padding(.top, 40)
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .padding(.top, 8)
            
            noArchiveSpotView
                .background(.gray20)
        }
    }
    
    private var ArchiveView: some View {
 
        ScrollView {
            VStack(spacing: 0) {
                myProfileView
                    .padding(.top, 40)
                
                archiveSpotBar
                    .padding(.top, 40)
                
                archiveSpotView
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .padding(.top, 4)
        }
        .background(.gray20)
       
    }
    
    private var myProfileView: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(store.profileImage)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            HStack(spacing: 6) {
                Text(store.nickname)
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
                
                Text("변경")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.blue100)
                    .asButton {
                        store.send(.viewEvent(.tappedProfileEdit))
                    }
            }
            .padding(.top, 16)
            
            Text(verbatim: store.email)
                .textStyle(.captionM)
                .foregroundStyle(.textInfo)
        }
    }
    
    private var archiveSpotBar: some View {
        VStack {
            HStack {
                Text("내가 등록한 스팟")
                    .textStyle(.subtitleSM)
                    .foregroundStyle(.blue100)
                    .padding(.leading, 15)
                
                Spacer()
                
                Text("\(store.spotCount)")
                    .textStyle(.subtitleSM)
                    .foregroundStyle(.blue100)
                    .padding(.trailing, 15)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.blue10)
        }
    }
    
    private var archiveSpotView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 4) {
            
            ForEach(store.mySpots, id: \.spotId) { item in
                myPageItem(item)
                    .asButton {
                        store.send(.viewEvent(.tappedSpot(item.spotId)))
                    }
            }
        }
    }
    
    private var noArchiveSpotView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image("SearchFail")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.4)
            
            Text("아직 등록한 스팟이 없어요!")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDisabled)
                .padding(.top, 12)
            
            Text("첫 스팟 등록하기")
                .hashTagStyle(backgroundColor: .navy100, textColor: .white, font: .subtitleM, verticalPadding: 10, horizontalPadding: 60, cornerRadius: 38)
                .padding(.top, 12)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
}

extension MyPageView {
    private func myPageItem(_ item: ArchiveListEntity) -> some View {
        DownImageView(url: item.representativeImageUrl, option: .max, fallBackImg: "ImageDefault")
            .aspectRatio(1, contentMode: .fill)
    }
}
