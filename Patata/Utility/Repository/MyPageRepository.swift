//
//  MyPageRepository.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation
import ComposableArchitecture

final class MyPageRepository: @unchecked Sendable {
    
    @Dependency(\.archiveMapper) var mapper
    @Dependency(\.networkManager) var networkManager
    
    func chageNickname(nickname: String) async throws(PAError) -> Bool {
        let isSuccess = try await networkManager.requestNetworkWithRefresh(dto: APIResponseErrorDTO.self, router: MyPageRouter.changeNickname(NicknameRequestDTO(nickName: nickname))).isSuccess
        
        if isSuccess {
            UserDefaultsManager.nickname = nickname
        }
        
        return isSuccess
    }
    
    func fetchMySpots() async throws(PAError) -> MySpotsEntity {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: MySpotDTO.self, router: MyPageRouter.fetchMySpot).result
        
        return await mapper.dtoToEntity(dto)
    }
    
    func fetchUser() async throws(PAError) -> MyPageEntity {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: MyPageDTO.self, router: MyPageRouter.fetchMyPage).result
        
        return mapper.dtoToEntity(dto)
    }
    
    func uploadImage(image: Data) async throws(PAError) -> Bool {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: AddSpotDTO.self, router: MyPageRouter.changeImage(image)).isSuccess
        
        return dto
    }
}

extension MyPageRepository: DependencyKey {
    static let liveValue: MyPageRepository = MyPageRepository()
}

extension DependencyValues {
    var myPageRepository: MyPageRepository {
        get { self[MyPageRepository.self] }
        set { self[MyPageRepository.self] = newValue }
    }
}
