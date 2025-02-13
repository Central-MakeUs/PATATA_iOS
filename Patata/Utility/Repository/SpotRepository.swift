//
//  SpotRepository.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation
import ComposableArchitecture

// categoryId: Int, page: Int = 0, size: Int = 10, latitude: Double? = nil, longitude: Double? = nil, sortBy: String = "RECOMMEND"

final class SpotRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.spotMapper) var mapper
}

extension SpotRepository {
    func fetchSpotCategory(
        category: CategoryCase,
        page: Int = 0,
        latitude: Double = 0,
        longitude: Double = 0,
        sortBy: String = "RECOMMEND"
    ) async throws(PAError) -> [SpotEntity] {
        
        let dto = try await networkManager.requestNetworkWithRefresh(
            dto: SpotCategoryDTO.self,
            router: SpotRouter.fetchCategorySpot(
                all: category.rawValue == 0,
                categoryId: category.rawValue,
                page: page,
                latitude: latitude,
                longitude: longitude,
                sortBy: sortBy
            )
        ).result
        
        return await mapper.dtoToEntity(dto.spots)
    }
    
    func fetchTodaySpot() async throws(PAError) -> [TodaySpotEntity] {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: TodaySpotDTO.self, router: SpotRouter.fetchTodayMain).result
        
        return await mapper.dtoToEntity(dto)
    }
    
    func fetchSearch(
        searchText: String,
        page: Int = 0,
        latitude: Double = 0,
        longitude: Double = 0,
        sortBy: FilterCase
    ) async throws(PAError) -> SearchSpotCountEntity {
        let dto = try await networkManager.requestNetworkWithRefresh(
            dto: SearchSpotDTO.self,
            router: SpotRouter.fetchSearchResult(
                searchText: searchText,
                page: page,
                latitude: latitude,
                longitude: longitude,
                sortBy: sortBy.rawValue
            )
        ).result
        
        return await mapper.dtoToEntity(dto)
    }
    
    func fetchSpot(spotId: String) async throws(PAError) -> SpotDetailEntity {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: SpotDetailDTO.self, router: SpotRouter.fetchSpot(spotId)).result
        
        return await mapper.dtoToEntity(dto)
    }
    
    func deleteSpot(spotId: Int) async throws(PAError) {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: DeleteSpotDTO.self, router: SpotRouter.deleteSpot(spotId))
        
        print("success", dto)
    }
}

extension SpotRepository: DependencyKey {
    static let liveValue: SpotRepository = SpotRepository()
}

extension DependencyValues {
    var spotRepository: SpotRepository {
        get { self[SpotRepository.self] }
        set { self[SpotRepository.self] = newValue }
    }
}
