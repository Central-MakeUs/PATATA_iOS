//
//  BottomSheetItem.swift
//  Patata
//
//  Created by 김진수 on 1/21/25.
//

import SwiftUI

struct BottomSheetItem: View {
    let title: String?
    let delete: Bool
    let items: [String]
    let tappedItem: (String) -> Void
    
    init(title: String? = nil, delete: Bool = false, items: [String], tappedItem: @escaping (String) -> Void) {
        self.title = title
        self.delete = delete
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
                .foregroundStyle(delete && item == "게시글 삭제하기" ? .red100 : .black)
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
