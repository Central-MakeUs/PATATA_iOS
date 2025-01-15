//
//  CategoryView.swift
//  Patata
//
//  Created by 김진수 on 1/16/25.
//

import SwiftUI

struct CategoryView: View {
    
    let categoryItem: CategoryItem
    var isSelected: Bool
    
    var onSelect: () -> Void
    
    var body: some View {
        contentView
    }
}

extension CategoryView {
    private var contentView: some View {
        Text(categoryItem.item)
            .foregroundStyle(isSelected ? .blue100 : .textInfo)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? .blue100 : .gray30, lineWidth: 2)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .onTapGesture {
                onSelect()
            }
    }
}
