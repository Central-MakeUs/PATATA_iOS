//
//  SpotMarkImage.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import Foundation

enum SpotMarkerImage {
    static let housePin: String = "HousePin"
    static let inActivePin: String = "InActivePin"
    static let activePin: String = "ActivePin"
    static let naturePin: String = "NaturePin"
    static let myPin: String = "MyPin"
    static let nightPin: String = "NightPin"
    static let recommendPin: String = "RecommendPin"
    static let snapPin: String = "SnapPin"
    static let archivePin: String = "ArchivePin"
    
    static func getMarkerImage(category: CategoryCase) -> String {
        switch category {
        case .all:
            return ""
        case .recommendSpot:
            return recommendPin
        case .snapSpot:
            return snapPin
        case .nightSpot:
            return nightPin
        case .houseSpot:
            return housePin
        case .natureSpot:
            return naturePin
        }
    }
}
