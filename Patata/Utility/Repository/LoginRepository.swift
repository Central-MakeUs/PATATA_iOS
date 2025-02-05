//
//  LoginRepository.swift
//  Patata
//
//  Created by 김진수 on 2/5/25.
//

import Foundation
import ComposableArchitecture

struct Nick: DTO, Encodable {
    let nickName: String
}

final class LoginRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.loginMapper) var mapper
}

extension LoginRepository {
    func googleLogin(idToken: String) async throws(PAError) -> LoginEntity {
        let data = try await networkManager.requestNetwork(dto: LoginDTO.self, router: LoginRouter.google(GoogleLoginRequestDTO(idToken: idToken)))
        
        return mapper.dtoToEntity(data)
    }
    
    func appleLogin(identityToken: String) async throws(PAError) -> LoginEntity {
        let data = try await networkManager.requestNetwork(dto: LoginDTO.self, router: LoginRouter.apple(AppleLoginRequestDTO(identityToken: identityToken)))
        
        return mapper.dtoToEntity(data)
    }
}

extension LoginRepository: DependencyKey {
    static let liveValue: LoginRepository = LoginRepository()
}

extension DependencyValues {
    var loginRepository: LoginRepository {
        get { self[LoginRepository.self] }
        set { self[LoginRepository.self] = newValue }
    }
}
