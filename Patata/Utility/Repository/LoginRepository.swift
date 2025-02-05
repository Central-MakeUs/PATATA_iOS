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
    
    func googleLogin(idToken: String) async -> LoginDTO? {
        do {
            return try await networkManager.requestNetwork(dto: LoginDTO.self, router: LoginRouter.google(GoogleLoginRequestDTO(idToken: idToken)))
        } catch {
            print("error", error)
            
            return nil
        }
    }
    
    func changeNickName() async {
        do {
            let result = try await networkManager.requestNetworkWithRefresh(dto: Nick.self, router: LoginRouter.nick)
            
            print("success", result)
        } catch {
            print("error!!!!!!", error)
        }
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
