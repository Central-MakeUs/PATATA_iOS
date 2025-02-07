//
//  SpotEntity.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation

struct SpotEntity: Entity {
    let spotId: Int
    let spotAddress: String
    let spotName: String
    let category: CategoryCase
    let imageUrl: String?
    let reviews: Int
    let spotScraps: Int
    let isScraped: Bool
    let tags: [String]
}
