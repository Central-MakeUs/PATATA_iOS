//
//  MyPageView.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import SwiftUI

struct MyPageView: View {
    private let imageCount: Int = 0
    
    var body: some View {
        contentView
    }
}

extension MyPageView {
    private var contentView: some View {
//        VStack(spacing: 0) {
//            fakeNavgationBar
//                .padding(.bottom, 4)
//                .background(.white)
//            
//            if imageCount == 0 {
//                noArchiveView
//            } else {
//                ArchiveView
//                    .padding(.top, 50)
//            }
//        }
//        .background(.gray20)
        
        VStack(spacing: 0) {
            fakeNavgationBar
                .padding(.bottom, 4)
                
            if imageCount == 0 {
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
            Image("MyPageActive")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            HStack(spacing: 6) {
                Text("가나다라마바사")
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
                
                Text("변경")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.blue100)
                    .asButton {
                        print("tap")
                    }
            }
            .padding(.top, 16)
            
            Text(verbatim: "aafadsfads@gmail.com")
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
                
                Text("6")
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
            ForEach(0..<2) { _ in
                Rectangle()
                    .foregroundStyle(.red)
                    .aspectRatio(1, contentMode: .fit)
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
