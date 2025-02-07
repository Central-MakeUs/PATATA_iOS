//
//  TodayRecommendView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct TodayRecommendView: View {
    @State var isValid: Bool = false // 여기는 걍 스팟 데이터만 받자
    let item: SpotEntity
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            contentView
                .padding(.horizontal, 15)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            RecommendSpotIconMark()
                .offset(x: -20, y: -5)
        }
    }
}


extension TodayRecommendView {
    private var contentView: some View {
           VStack(spacing: 10) {
               DownImageView(url: URL(string: item.imageUrl ?? ""), option: .max, fallBackImg: "ImageDefault")
                   .aspectRatio(contentMode: .fit)
                   .frame(maxHeight: .infinity)
                   .clipShape(RoundedRectangle(cornerRadius: 8))
                   .padding(.top, 15)
                   
               HStack {
                   
                   ForEach(item.tags, id: \.self) { tag in
                       Text(tag)
                           .hashTagStyle(backgroundColor: .gray20, textColor: .gray80)
                   }
                   
                   Spacer()
                   
                   SpotArchiveButton(height: 24, width: 24, isSaved: $isValid)
               }
               .padding(.bottom, 10)
           }
           
       }
}
