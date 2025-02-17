//
//  MapMapper.swift
//  Patata
//
//  Created by 김진수 on 2/15/25.
//

import Foundation
import ComposableArchitecture

struct MapMapper: Sendable {
    func dtoToEntity(_ dtos: [MapSpotItemDTO]) async -> [MapSpotEntity] {
        return await dtos.asyncMap { await dtoToEntity($0) }
    }
    
    func dtoToEntity(_ dtos: [AddSpotItemDTO]) async -> [MapSpotEntity] {
        return await dtos.asyncMap { dtoToEntity($0) }.asyncMap { entityToEntity($0) }
    }
    
    func dtoToEntity(_ dto: MapSpotItemDTO) async -> MapSpotEntity {
        return await MapSpotEntity(
            spotId: dto.spotId,
            spotName: dto.spotName,
            spotAddress: dto.spotAddress,
            spotAddressDetail: dto.spotAddressDetail,
            coordinate: Coordinate(latitude: dto.latitude, longitude: dto.longitude),
            category: CategoryCase(rawValue: dto.categoryId) ?? .houseSpot,
            tags: dto.tags,
            images: dto.images.asyncMap { URL(string: $0) },
            isScraped: dto.isScraped,
            distance: DistanceUnit.formatDistance(dto.distance)
        )
    }
}

extension MapMapper {
    private func dtoToEntity(_ dto: AddSpotItemDTO) -> AddSpotEntity {
        return AddSpotEntity(spotId: dto.spotId, spotName: dto.spotName, coord: Coordinate(latitude: dto.latitude, longitude: dto.longitude))
    }
    
    private func entityToEntity(_ dto: AddSpotEntity) -> MapSpotEntity {
        return MapSpotEntity(spotId: dto.spotId, spotName: "", spotAddress: "", spotAddressDetail: "", coordinate: dto.coord, category: .all, tags: [], images: [], isScraped: false, distance: "")
    }
}

extension MapMapper: DependencyKey {
    static let liveValue: MapMapper = MapMapper()
}

extension DependencyValues {
    var mapMapper: MapMapper {
        get { self[MapMapper.self] }
        set { self[MapMapper.self] = newValue }
    }
}
