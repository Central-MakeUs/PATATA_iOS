//
//  TodayRecommendView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct TodayRecommendView: View {
    @State var isValid: Bool = false
    let string: String
    
    var body: some View {
        ZStack {
            contentView
                .padding(.horizontal, 15)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 8)
    }
}


extension TodayRecommendView {
    private var contentView: some View {
           VStack(spacing: 10) {
               imageView
                   .padding(.top, 15)
                   .asButton {
                       print("a")
                   }
                   
               HStack {
                   Text(string)
                       .hashTagStyle(backgroundColor: .gray20, textColor: .gray80)
                   
                   Text("#djdjd")
                       .hashTagStyle(backgroundColor: .gray20, textColor: .gray80)
                   
                   Spacer()
                   
                   SpotArchiveButton(height: 24, width: 24, isSaved: $isValid)
               }
               .padding(.bottom, 10)
           }
           
       }
       
       private var imageView: some View {
           Rectangle()
               .frame(maxHeight: .infinity)
               .foregroundStyle(.green)
               .clipShape(RoundedRectangle(cornerRadius: 8))
       }
}
