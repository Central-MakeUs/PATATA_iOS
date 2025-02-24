//
//  SpotMapper.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation
import ComposableArchitecture

struct SpotMapper: Sendable {
    func dtoToEntity(_ dtos: SpotCategoryItemDTO) async -> CategorySpotPageEntity {
        return await CategorySpotPageEntity(currentPage: dtos.currentPage, totalPages: dtos.totalPages, totalCount: dtos.totalCount, spots: dtos.spots.asyncMap { dtoToEntity($0) })
    }
    
    func dtoToEntity(_ dtos: [TodaySpotItemDTO]) async -> [TodaySpotEntity] {
        return await dtos.asyncMap { dtoToEntity($0)}
    }
    
    func dtoToEntity(dtos: [TodaySpotListItemDTO]) async -> [TodaySpotListEntity] {
        return await dtos.asyncMap { dtoToEntity($0) }
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
    
    func dtoToEntity(_ dto: SpotDetailItemDTO) async -> SpotDetailEntity {
        return await SpotDetailEntity(
            spotId: dto.spotId,
            isAuthor: dto.isAuthor,
            spotAddress: dto.spotAddress,
            spotAddressDetail: dto.spotAddressDetail ?? "",
            spotName: dto.spotName,
            spotDescription: dto.spotDescription,
            categoryId: CategoryCase(rawValue: dto.categoryId) ?? .houseSpot,
            memberName: dto.memberName,
            images: dto.images.asyncMap { URL(string: $0) },
            reviewCount: dto.reviewCount,
            isScraped: dto.isScraped,
            tags: dto.tags,
            reviews: await dto.reviews.asyncMap { dtoToEntity($0) },
            spotCoord: Coordinate(latitude: dto.latitude, longitude: dto.longitude),
            memberId: dto.memberId
        )
    }
    
    func dataToRequestDTO(
        spotName: String,
        spotAddress: String,
        spotAddressDetail: String,
        coord: Coordinate,
        spotDescription: String,
        categoryId: Int,
        tags: [String],
        images: [Data]
    ) async -> CreateSpotRequestDTO {
        return await CreateSpotRequestDTO(
            spotName: spotName,
            spotAddress: spotAddress,
            spotAddressDetail: spotAddressDetail,
            latitude: coord.latitude,
            longitude: coord.longitude,
            spotDescription: spotDescription,
            categoryId: categoryId,
            tags: tags,
            images: images
                .enumerated()
                .asyncMap {
                    dataToRequestDTO(
                        images: $1,
                        index: $0
                    )
                }
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
            spotId: dto.spotId,
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
            spotId: dto.spotId,
            spotName: dto.spotName,
            imageUrl: URL(string: dto.imageUrl ?? ""),
            spotScraps: dto.spotScraps,
            isScraped: dto.isScraped,
            reviews: dto.reviews,
            distance: DistanceUnit.formatDistance(dto.distance)
        )
    }
    
    private func dtoToEntity(_ dto: SpotDetailReviewDTO) -> SpotDetailReviewEntity {
        print("dfsafadsfads", dto.reviewDate)
        return SpotDetailReviewEntity(reviewId: dto.reviewId, memberName: dto.memberName, reviewText: dto.reviewText, reviewData: DateManager.shared.toDateString(dto.reviewDate))
    }
    
    private func dtoToEntity(_ dto: TodaySpotListItemDTO) -> TodaySpotListEntity {
        return TodaySpotListEntity(
            spotId: dto.spotId,
            spotAddress: dto.spotAddress,
            spotAddressDetail: dto.spotAddressDetail ?? "",
            spotName: dto.spotName,
            categoryId: CategoryCase
                .getCategory(
                    id: dto.categoryId
                ),
            images: dto.images
                .map {
                    URL(
                        string: $0
                    )
                },
            isScraped: dto.isScraped,
            distance: DistanceUnit.formatDistance(dto.distance),
            tags: dto.tags
        )
    }
    
    private func dataToRequestDTO(images: Data, index: Int) -> RequestSpotImageDTO {
        return RequestSpotImageDTO(file: images, isRepresentative: true, sequence: index)
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
