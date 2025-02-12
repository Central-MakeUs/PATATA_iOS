//
//  MyPageRepository.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation
import ComposableArchitecture

final class MyPageRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    
    func chageNickname(nickname: String) async throws(PAError) -> Bool {
        return try await networkManager.requestNetworkWithRefresh(dto: APIResponseErrorDTO.self, router: MyPageRouter.changeNickname(NicknameRequestDTO(nickName: nickname))).isSuccess
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
