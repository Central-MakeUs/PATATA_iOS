//
//  Coordinate.swift
//  Patata
//
//  Created by 김진수 on 2/11/25.
//

import Foundation

struct Coordinate: Equatable, Hashable {
    var latitude: Double
    var longitude: Double
}

struct MBRCoordinates: Equatable {
    let northEast: Coordinate
    let southWest: Coordinate
}
