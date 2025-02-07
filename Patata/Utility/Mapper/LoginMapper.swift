//
//  LoginMapper.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation
import ComposableArchitecture

struct LoginMapper: Sendable {
    func dtoToEntity(_ dtos: LoginDTO) -> LoginEntity {
        
        UserDefaultsManager.accessToken = dtos.result.accessToken
        UserDefaultsManager.refreshToken = dtos.result.refreshToken
        
        return LoginEntity(
            nickName: dtos.result.nickName,
            email: dtos.result.email
        )
    }
}

extension LoginMapper: DependencyKey {
    static let liveValue: LoginMapper = LoginMapper()
}

extension DependencyValues {
    var loginMapper: LoginMapper {
        get { self[LoginMapper.self] }
        set { self[LoginMapper.self] = newValue }
    }
}
