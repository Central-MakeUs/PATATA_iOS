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
                .padding(.horizontal, 12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .redacted(reason: item.spotName.isEmpty ? .placeholder : [])
            
            if item.category == .recommendSpot {
                RecommendSpotIconMark()
                    .offset(x: -20, y: -5)
            }
        }
    }
}


extension TodayRecommendView {
    private var contentView: some View {
           VStack(spacing: 0) {
               if item.spotName.isEmpty {
                   Rectangle()
                       .aspectRatio(5/6, contentMode: .fill)
                       .clipShape(RoundedRectangle(cornerRadius: 8))
                       .foregroundStyle(.gray30)
                       .padding(.top, 13)
               } else {
                   DownImageView(url: URL(string: item.imageUrl ?? ""), option: .custom(CGSize(width: 600, height: 600)), fallBackImg: "ImageDefault")
                       .aspectRatio(5/6, contentMode: .fill)
                       .clipped()
                       .clipShape(RoundedRectangle(cornerRadius: 8))
                       .padding(.top, 13)
                       .overlay {
                           ZStack {
                               LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.clear, location: 0.78),
                                    .init(color: Color.black.opacity(0.3), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                               )
                               
                               VStack(spacing: 0){
                                   Spacer()
                                   
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
                                           .lineLimit(1)
                                       
                                       Spacer()
                                   }
                                   .offset(x: -8, y: 5)
                                   
                                   HStack {
                                       Text(item.spotName)
                                           .textStyle(.subtitleL)
                                           .foregroundStyle(.white)
                                           .lineLimit(1)
                                       
                                       Spacer()
                                   }
                               }
                               .padding(.leading, 8)
                               .padding(.bottom, 12)
                           }
                           .clipShape(RoundedRectangle(cornerRadius: 8))
                       }
               }
               
               HStack {
                   ForEach(item.tags, id: \.self) { tag in
                       Text("#\(tag)")
                           .hashTagStyle(backgroundColor: .gray20, textColor: .gray80, verticalPadding: 8, horizontalPadding: 12, cornerRadius: 20)
                   }
                   
                   Spacer()
                   
                   SpotArchiveButton(height: 24, width: 24, viewState: .home, isSaved: item.isScraped) {
                       onToggleScrap()
                   }
               }
               .padding(.vertical, 12)
           }
           
       }
}
