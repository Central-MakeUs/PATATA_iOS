//
//  CategoryRecommendView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct CategoryRecommendView: View {
    @State var isValid: Bool = false
    let spotItem: SpotEntity
    
    var body: some View {
        contentView
    }
}

extension CategoryRecommendView {
    private var contentView: some View {
        HStack(alignment: .top) {
            DownImageView(url: URL(string: spotItem.imageUrl ?? ""), option: .min, fallBackImg: "ImageDefault")
                .aspectRatio(contentMode: .fit)
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
                Text(spotItem.spotAddress)
                    .foregroundStyle(.textInfo)
                    .textStyle(.captionM)
                
                Spacer()
            }
            
            Text(spotItem.spotName)
                .foregroundStyle(.textDefault)
                .textStyle(.subtitleSM)
                .padding(.top, 1)
                .padding(.bottom, 6)
            
            SaveCommentCountView(archiveCount: 117, commentCount: 117, imageSize: 12)
                .padding(.bottom, 25)
            
            HStack {
                ForEach(spotItem.tags, id: \.self) { tag in
                    Text(tag)
                        .hashTagStyle()
                }
            }
        }
    }
    
    
}
