//
//  LoginRepository.swift
//  Patata
//
//  Created by 김진수 on 2/5/25.
//

import Foundation
import ComposableArchitecture

final class LoginRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    
    func googleLogin() {
        
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
