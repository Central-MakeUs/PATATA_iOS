//
//  CategoryItem.swift
//  Patata
//
//  Created by 김진수 on 1/16/25.
//

import Foundation

struct CategoryItem: Identifiable, Equatable {
    let id = UUID()
    
    let item: String
    let images: String
}
