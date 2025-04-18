//
//  CategoryRecommendView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct CategoryRecommendView: View {
    let spotItem: SpotEntity
    let tappedButton: () -> Void
    
    var body: some View {
        contentView
            .redacted(reason: spotItem.spotName.isEmpty ? .placeholder : [])
    }
}

extension CategoryRecommendView {
    private var contentView: some View {
        HStack(alignment: .top) {
            if spotItem.spotName.isEmpty {
                Rectangle()
                    .foregroundStyle(.gray30)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.leading, 10)
                    .padding(.vertical, 10)
            } else {
                DownImageView(url: URL(string: spotItem.imageUrl ?? ""), option: .mid, fallBackImg: "ImageDefault")
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .clipped()
                    .overlay {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.clear, location: 0.66),
                                    .init(color: Color.black.opacity(0.3), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            SpotArchiveButton(height: 40, width: 40, viewState: .category, isSaved: spotItem.isScraped) {
                                tappedButton()
                            }
                            .padding(.leading, 4)
                            .padding(.bottom, 4)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.leading, 10)
                    .padding(.vertical, 10)
            }
            
            ZStack(alignment: .topTrailing) {
                spotDesView
                    .padding(.top, 20)
                    .padding(.leading, 8)
                
                if spotItem.category == .recommendSpot {
                    Text("작가 추천 스팟")
                        .hashTagStyle(backgroundColor: .navy100, textColor: .blue50, font: .captionS, verticalPadding: 5, horizontalPadding: 10, cornerRadius: 30)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                }
            }
            
        }
    }
    
    private var spotDesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                limitText(spotItem.spotAddress.isEmpty ? "dddd" : spotItem.spotAddress, to: 10)
                    .foregroundStyle(.textInfo)
                    .textStyle(.captionM)
                
                Spacer()
            }
            
            
            Text(spotItem.spotAddress.isEmpty ? "dddd" : spotItem.spotName)
                .foregroundStyle(.textDefault)
                .textStyle(.subtitleSM)
                .padding(.top, 1)
                .padding(.bottom, 6)
            
            SaveCommentCountView(archiveCount: spotItem.spotScraps, commentCount: spotItem.reviews, imageSize: 12)
                .padding(.bottom, 25)
            
            HStack {
                ForEach(Array(spotItem.tags.enumerated()), id: \.offset) { _, tag in
                    Text(tag)
                        .hashTagStyle()
                }
            }
        }
    }
    
    
}
