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
    let tapChange: Bool
    let tappedItem: (String) -> Void
    
    @State private var selectedIndex: Int = 0
    
    init(title: String? = nil, delete: Bool = false, items: [String], tapChange: Bool = true, tappedItem: @escaping (String) -> Void) {
        self.title = title
        self.delete = delete
        self.items = items
        self.tapChange = tapChange
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
            
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                
                HStack {
                    Spacer()
                    
                    Text(item)
                        .textStyle(.subtitleM)
                    
                    Spacer()
                }
                .frame(height: 35)
                .foregroundStyle(delete ? (item == "게시글 삭제하기" ? .red100 : Color.textDefault) : tapChange ? (selectedIndex == index ? Color.textDefault : Color.textDisabled) : Color.textDefault)
                .asButton {
                    tappedItem(item)
                    selectedIndex = index
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
