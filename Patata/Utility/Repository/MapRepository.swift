//
//  MapRepository.swift
//  Patata
//
//  Created by 김진수 on 2/15/25.
//

import Foundation
import ComposableArchitecture

final class MapRepository: @unchecked Sendable {
    @Dependency(\.mapMapper) var mapper
    @Dependency(\.networkManager) var networkManager
    
    func fetchMap(
        mbrLocation: MBRCoordinates,
        userLocation: Coordinate,
        categoryId: Int,
        isSearch: Bool
    ) async throws(PAError) -> [MapSpotEntity] {
        
        let dtos = try await networkManager.requestNetworkWithRefresh(
            dto: MapSpotDTO.self,
            router: MapRouter.fetchMap(
                mbrLocation: mbrLocation,
                userLocation: userLocation,
                categoryId: categoryId,
                isSearch: isSearch
            )
        ).result
        
        return await mapper.dtoToEntity(dtos)
    }
}

extension MapRepository: DependencyKey {
    static let liveValue: MapRepository = MapRepository()
}

extension DependencyValues {
    var mapRepository: MapRepository {
        get { self[MapRepository.self] }
        set { self[MapRepository.self] = newValue }
    }
}

