//
//  MyPageRepository.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation
import ComposableArchitecture

//struct Nick: DTO, Encodable {
//    let nickName: String
//}

final class MyPageRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    
    func chageNickname(idToken: String) async -> LoginDTO? {
        do {
            return try await networkManager.requestNetwork(dto: LoginDTO.self, router: LoginRouter.google(GoogleLoginRequestDTO(idToken: idToken)))
        } catch {
            print("error", error)
            
            return nil
        }
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
