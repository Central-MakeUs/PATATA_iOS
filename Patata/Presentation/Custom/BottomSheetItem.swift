//
//  BottomSheetItem.swift
//  Patata
//
//  Created by 김진수 on 1/21/25.
//

import SwiftUI

struct BottomSheetItem: View {
    let title: String?
    let items: [String]
    let tappedItem: (String) -> Void
    
    init(title: String? = nil, items: [String], tappedItem: @escaping (String) -> Void) {
        self.title = title
        self.items = items
        self.tappedItem = tappedItem
    }
    
    var body: some View {
        contentView
    }
}

extension BottomSheetItem {
    private var contentView: some View {
        bottomItem
    }
    
    private var bottomItem: some View {
        VStack {
            
            if let title {
                Text(title)
                    .textStyle(.subtitleM)
                    .padding(.top, 2)
                    .padding(.bottom, 8)
                
                Divider()
                    .padding(.horizontal, 15)
            }
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Spacer()
                    
                    Text(item)
                        .textStyle(.subtitleM)
                    
                    Spacer()
                }
                .frame(height: 35)
                .asButton {
                    tappedItem(item)
                }
                
                if item != items.last {
                    Divider()
                        .padding(.horizontal, 15)
                }
                
            }
        }
        .background(.white)
    }
}
