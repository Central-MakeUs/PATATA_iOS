//
//  SaveCommentCountView.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI

struct SaveCommentCountView: View {
    let archiveCount: Int
    let commentCount: Int
    let imageSize: CGFloat
    
    var body: some View {
        saveCommentView
    }
}

extension SaveCommentCountView {
    private var saveCommentView: some View {
        HStack(spacing: 5) {
            HStack(spacing: 4) {
                Image("ScrapCount")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: imageSize)
                
                Text(String(archiveCount))
            }
            
            HStack(spacing: 4) {
                Image("CommentCount")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: imageSize)
                
                Text(String(commentCount))
            }
        }
        .foregroundStyle(.textDisabled)
        .textStyle(.captionS)
    }
}
