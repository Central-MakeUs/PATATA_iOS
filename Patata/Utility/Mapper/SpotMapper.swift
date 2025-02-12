//
//  SpotMapper.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation
import ComposableArchitecture

struct SpotMapper: Sendable {
    func dtoToEntity(_ dtos: [SpotDTO]) async -> [SpotEntity] {
        return await dtos.asyncMap { dtoToEntity($0) }
    }
    
    func dtoToEntity(_ dtos: [TodaySpotItemDTO]) async -> [TodaySpotEntity] {
        return await dtos.asyncMap { dtoToEntity($0)}
    }
    
    func dtoToEntity(_ dto: SearchSpotCountDTO) async -> SearchSpotCountEntity {
        return await SearchSpotCountEntity(
            currentPage: dto.currentPage,
            totalPages: dto.totalPages,
            totalCount: dto.totalCount,
            spots: dto.spots
                .asyncMap { dtoToEntity($0) }
        )
    }
}

extension SpotMapper {
    private func dtoToEntity(_ dto: SpotDTO) -> SpotEntity {
        SpotEntity(
            spotId: dto.spotId,
            spotAddress: dto.spotAddress,
            spotName: dto.spotName,
            category: .getCategory(id: dto.categoryId),
            imageUrl: dto.imageUrl,
            reviews: dto.reviews,
            spotScraps: dto.spotScraps,
            isScraped: dto.isScraped,
            tags: dto.tags
        )
    }
    
    private func dtoToEntity(_ dto: TodaySpotItemDTO) -> TodaySpotEntity {
        TodaySpotEntity(
            spotId: String(dto.spotId),
            spotAddress: dto.spotAddress,
            spotName: dto.spotName,
            category: .getCategory(id: dto.categoryId),
            imageUrl: dto.imageUrl,
            isScraped: dto.isScraped,
            tags: dto.tags
        )
    }
    
    private func dtoToEntity(_ dto: SearchSpotItemDTO) -> SearchSpotEntity {
        return SearchSpotEntity(
            spotId: String(dto.spotId),
            spotName: dto.spotName,
            imageUrl: URL(string: dto.imageUrl ?? ""),
            spotScraps: dto.spotScraps,
            isScraped: dto.isScraped,
            reviews: dto.reviews,
            distance: dto.distance
        )
    }
}

extension SpotMapper: DependencyKey {
    static let liveValue: SpotMapper = SpotMapper()
}

extension DependencyValues {
    var spotMapper: SpotMapper {
        get { self[SpotMapper.self] }
        set { self[SpotMapper.self] = newValue }
    }
}
