//
//  TodayRecommendView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct TodayRecommendView: View {
    let item: TodaySpotEntity
    let onToggleScrap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            contentView
                .padding(.horizontal, 15)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if item.category == .recommendSpot {
                RecommendSpotIconMark()
                    .offset(x: -20, y: -5)
            }
        }
    }
}


extension TodayRecommendView {
    private var contentView: some View {
           VStack(spacing: 10) {
               DownImageView(url: URL(string: item.imageUrl ?? ""), option: .mid, fallBackImg: "ImageDefault")
                   .aspectRatio(5/6, contentMode: .fit)
                   .clipped()
                   .clipShape(RoundedRectangle(cornerRadius: 8))
                   .padding(.top, 15)
                   
               HStack {
                   
                   ForEach(item.tags, id: \.self) { tag in
                       Text(tag)
                           .hashTagStyle(backgroundColor: .gray20, textColor: .gray80)
                   }
                   
                   Spacer()
                   
                   SpotArchiveButton(height: 24, width: 24, viewState: .home, isSaved: item.isScraped) {
                       onToggleScrap()
                   }
               }
               .padding(.bottom, 10)
           }
           
       }
}
