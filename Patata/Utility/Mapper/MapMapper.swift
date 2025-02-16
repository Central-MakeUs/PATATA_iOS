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
        return await dtos.asyncMap { dtoToEntity($0) }
    }
    
    func dtoToEntity(_ dtos: [AddSpotItemDTO]) async -> [MapSpotEntity] {
        return await dtos.asyncMap { dtoToEntity($0) }.asyncMap { entityToEntity($0) }
    }
}

extension MapMapper {
    private func dtoToEntity(_ dto: MapSpotItemDTO) -> MapSpotEntity {
        return MapSpotEntity(
            spotId: dto.spotId,
            spotName: dto.spotName,
            spotAddress: dto.spotAddress,
            spotAddressDetail: dto.spotAddressDetail,
            coordinate: Coordinate(latitude: dto.latitude, longitude: dto.longitude),
            category: CategoryCase(rawValue: dto.categoryId) ?? .houseSpot,
            tags: dto.tags,
            representativeImageUrl: dto.representativeImageUrl,
            isScraped: dto.isScraped,
            distance: DistanceUnit.formatDistance(dto.distance)
        )
    }
    
    private func dtoToEntity(_ dto: AddSpotItemDTO) -> AddSpotEntity {
        return AddSpotEntity(spotId: dto.spotId, spotName: dto.spotName, coord: Coordinate(latitude: dto.latitude, longitude: dto.longitude))
    }
    
    private func entityToEntity(_ dto: AddSpotEntity) -> MapSpotEntity {
        return MapSpotEntity(spotId: dto.spotId, spotName: "", spotAddress: "", spotAddressDetail: "", coordinate: dto.coord, category: .all, tags: [], representativeImageUrl: "", isScraped: false, distance: "")
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
