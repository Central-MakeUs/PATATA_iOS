//
//  CoordinateDTO.swift
//  Patata
//
//  Created by 김진수 on 2/11/25.
//

import Foundation
import RealmSwift

final class CoordinateDTO: Object, @unchecked Sendable {
    // 고정된 ID 사용
    @Persisted(primaryKey: true) var id: String = "singleton_coordinate"
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    convenience init(coordinate: Coordinate) {
        self.init()
        self.id = "singleton_coordinate" // 항상 같은 ID 사용
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func toDomain() -> Coordinate {
        return Coordinate(
            latitude: latitude,
            longitude: longitude
        )
    }
}
