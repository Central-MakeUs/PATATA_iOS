//
//  FilterCase.swift
//  Patata
//
//  Created by 김진수 on 2/13/25.
//

import Foundation

enum FilterCase: String {
    case recommend = "RECOMMEND"
    case distance = "DISTANCE"
    
    static func getFilter(text: String) -> FilterCase {
        if text == "추천순" {
            return .recommend
        } else {
            return .distance
        }
    }
}
