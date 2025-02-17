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
               DownImageView(url: URL(string: item.imageUrl ?? ""), option: .custom(CGSize(width: 600, height: 600)), fallBackImg: "ImageDefault")
                   .aspectRatio(5/6, contentMode: .fit)
                   .clipped()
                   .clipShape(RoundedRectangle(cornerRadius: 8))
                   .padding(.top, 15)
                   .overlay(alignment: .bottomLeading) {
                       VStack(spacing: 0){
                           HStack(spacing: 0) {
                               Image("WhitePin")
                                   .resizable()
                                   .aspectRatio(contentMode: .fit)
                                   .frame(width: 30, height: 30)
                                   .padding(.leading, 0)
                               
                               Text(item.spotAddress)
                                   .textStyle(.subtitleXS)
                                   .foregroundStyle(.white)
                                   .offset(x: -4)
                               
                               Spacer()
                           }
                           .offset(x: -8)
                           
                           HStack {
                               Text(item.spotName)
                                   .textStyle(.subtitleL)
                                   .foregroundStyle(.white)
                               
                               Spacer()
                           }
                       }
                       .padding(.leading, 8)
                       .padding(.bottom, 12)
                   }
                   
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
