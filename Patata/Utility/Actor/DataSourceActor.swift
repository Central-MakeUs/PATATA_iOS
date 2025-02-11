//
//  DataSourceActor.swift
//  Patata
//
//  Created by 김진수 on 2/11/25.
//

import Foundation
import RealmSwift

final actor DataSourceActor {
    
    private var realm: Realm?
    
    init() {
        Task {
            await self.setup()
        }
    }
    
    private func setup() async { // 내쓰레드
        do {
            realm = try await Realm.open()
        } catch {
            realm = nil
        }
    }
    
    func coordCreate(coord: Coordinate) async throws(RealmError) -> Void {
        do {
            
            try await realm?.asyncWrite {
#if DEBUG
                print("realm", realm?.configuration.fileURL ?? "")
#endif
                realm?.create(
                    CoordinateDTO.self,
                    value: [
                        "id": "singleton_coordinate",
                        "latitude": coord.latitude,
                        "longitude": coord.longitude
                    ],
                    update: .modified)
            }
            
            return ()
            
        } catch {
            throw .createFail
        }
    }
    
    func fetch() async -> Coordinate {
        guard let realm else {
            print("firstFail")
            return Coordinate(latitude: 126.9784147, longitude: 37.5666885)
        }
        
        let dto = realm.objects(CoordinateDTO.self)
        
        if let coord = dto.first {
            print("first", coord)
            return coord.toDomain()
        } else {
            print("second fail")
            return Coordinate(latitude: 126.9784147, longitude: 37.5666885)
        }
    }
}
