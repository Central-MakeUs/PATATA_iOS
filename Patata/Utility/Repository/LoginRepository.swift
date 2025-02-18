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
        
        UserDefaultsManager.appleUser = false
        
        return mapper.dtoToEntity(data)
    }
    
    func appleLogin(identityToken: String) async throws(PAError) -> LoginEntity {
        let data = try await networkManager.requestNetwork(dto: LoginDTO.self, router: LoginRouter.apple(AppleLoginRequestDTO(identityToken: identityToken)))
        
        UserDefaultsManager.appleUser = true
        
        return mapper.dtoToEntity(data)
    }
    
    func revokeApple(authToken: String) async throws(PAError) -> Bool {
        let isValid = try await networkManager.requestNetworkWithRefresh(dto: AddSpotDTO.self, router: LoginRouter.revokeApple(auth: authToken)).isSuccess
        
        return isValid
    }
    
    func revokeGoogle(accessToken: String) async throws(PAError) -> Bool {
        let isValid = try await networkManager.requestNetworkWithRefresh(dto: AddSpotDTO.self, router: LoginRouter.revokeGoogle(accessToken: accessToken)).isSuccess
        
        return isValid
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
