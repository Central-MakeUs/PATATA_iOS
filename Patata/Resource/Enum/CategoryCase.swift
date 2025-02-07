//
//  CategoryCase.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation

enum CategoryCase: Int, CaseIterable, Identifiable {
    var id: Self {
        return self
    }
    
    case all = 0
    case recommendSpot = 1
    case snapSpot = 2
    case nightSpot = 3
    case houseSpot = 4
    case natureSpot = 5
    
    static func getCategory(id: Int) -> CategoryCase {
        switch id {
        case 1:
            return .recommendSpot
        case 2:
            return .snapSpot
        case 3:
            return .nightSpot
        case 4:
            return .houseSpot
        case 5:
            return .natureSpot
        default:
            return .all
        }
    }
}

extension CategoryCase {
    func getCategoryCase() -> (title: String, image: String?) {
        switch self {
        case .all:
            (title: "전체", image: nil)
        case .recommendSpot:
            (title: "작가 추천", image: "RecommendIcon")
        case .snapSpot:
            (title: "스냅스팟", image: "SnapIcon")
        case .nightSpot:
            (title: "시크한 야경", image: "NightIcon")
        case .houseSpot:
            (title: "일상 속 공간", image: "HouseIcon")
        case .natureSpot:
            (title: "싱그러운 자연", image: "NatureIcon")
        }
    }
}
