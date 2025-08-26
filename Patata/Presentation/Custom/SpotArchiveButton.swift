//
//  SpotArchiveButton.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct SpotArchiveButton: View {
    let height: CGFloat
    let width: CGFloat
    let viewState: ViewState
    let onToggleScrap: () -> Void
    
    enum ViewState {
        case home
        case other
        case category
    }
    
    var isSaved: Bool
    
    init(height: CGFloat, width: CGFloat, viewState: ViewState = .other, isSaved: Bool, onToggleScrap: @escaping () -> Void) {
        self.height = height
        self.width = width
        self.viewState = viewState
        self.isSaved = isSaved
        self.onToggleScrap = onToggleScrap
    }
    
    var body: some View {
        Group {
            if viewState == .category {
                Image(isSaved ? "ArchiveActiveIcon" : "ArchiveIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .foregroundStyle(isSaved ? .black : .white)
                    .onTapGesture {
                        onToggleScrap()
                    }
            } else {
                Image(isSaved ? "ArchiveActive" : "HomeArchiveIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .foregroundStyle(isSaved ? .black : .white)
                    .highPriorityGesture(
                        TapGesture()
                            .onEnded {
                                onToggleScrap()
                            }
                    )
            }
        }
    }
}
