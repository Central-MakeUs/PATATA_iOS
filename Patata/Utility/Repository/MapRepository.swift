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
    
    func checkValidSpot(coord: Coordinate) async throws(PAError) -> [MapSpotEntity] {
        do {
            let isSuccess = try await networkManager.requestNetworkWithRefresh(dto: AddSpotDTO.self, router: MapRouter.checkSpotCount(coord)).isSuccess
            
            print("success", isSuccess)
            
            return []
        } catch {
            switch error {
            case let .checkAddSpot(addFailDTO):
                return await mapper.dtoToEntity(addFailDTO.result)
            default:
                throw error
            }
        }
    }
    
    func fetchSearchSpot(userLocation: Coordinate, mbrLocation: MBRCoordinates? = nil, spotName: String) async throws(PAError) -> MapSpotEntity? {
        do {
            let dtos = try await networkManager.requestNetworkWithRefresh(dto: SearchMapDTO.self, router: MapRouter.searchMap(spotName: spotName, mbrLocation: mbrLocation, userLocation: userLocation)).result
            
            return await mapper.dtoToEntity(dtos)
        } catch {
            switch error {
            case .errorMessage(.search(.noData)):
                return nil
            default:
                throw error
            }
        }
    }
    
    func fetchMySpotList(
        mbrLocation: MBRCoordinates,
        userLocation: Coordinate,
        categoryId: Int,
        isSearch: Bool,
        page: Int
        ) async throws(PAError) -> MyListMapSpotEntity {
            let dto = try await networkManager.requestNetworkWithRefresh(dto: MyListMapSpotDTO.self, router: MapRouter.fetchMySpotList(mbrLocation: mbrLocation, userLocation: userLocation, categoryId: categoryId, isSearch: isSearch, page: page)).result
            
            return await mapper.dtoToEntity(dto)
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

