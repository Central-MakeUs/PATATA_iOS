//
//  TodaySpotEntity.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation

struct TodaySpotEntity: Entity {
    let spotId: String
    let spotAddress: String
    let spotName: String
    let category: CategoryCase
    let imageUrl: String?
    let isScraped: Bool
    let tags: [String]
}
