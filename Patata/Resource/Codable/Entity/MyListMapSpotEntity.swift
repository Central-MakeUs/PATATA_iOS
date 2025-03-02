//
//  MyListMapSpotEntity.swift
//  Patata
//
//  Created by 김진수 on 3/2/25.
//

import Foundation

struct MyListMapSpotEntity: Entity {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let spots: [MapSpotEntity]
}
