//
//  CategoryRecommendView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct CategoryRecommendView: View {
    @State var isValid: Bool = false
    
    var body: some View {
        contentView
    }
}

extension CategoryRecommendView {
    private var contentView: some View {
        HStack(alignment: .top) {
            Rectangle()
                .foregroundStyle(.red)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottomLeading) {
                    SpotArchiveButton(height: 24, width: 24, isSaved: $isValid)
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                }
                .padding(.leading, 10)
                .padding(.vertical, 10)
                
            
            ZStack(alignment: .topTrailing) {  // ZStack으로 변경
                    spotDesView
                        .padding(.top, 20)
                        .padding(.leading, 8)
                    
                    Text("작가 추천 스팟")
                        .hashTagStyle(backgroundColor: .navy100, textColor: .blue50, font: .captionS)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                }
        }
        
    }
    
    private var spotDesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("서울시 마포구")
                    .foregroundStyle(.textInfo)
                    .textStyle(.captionM)
                
                Spacer()
            }
            
            Text("서울숲 은행길")
                .foregroundStyle(.textDefault)
                .textStyle(.subtitleSM)
                .padding(.top, 1)
                .padding(.bottom, 6)
            
            SaveCommentCountView(archiveCount: 117, commentCount: 117, imageSize: 12)
                .padding(.bottom, 25)
            
            HStack {
                Text("#가을사진")
                    .hashTagStyle()
                Text("#자연스팟")
                    .hashTagStyle()
            }
        }
    }
    
    
}
