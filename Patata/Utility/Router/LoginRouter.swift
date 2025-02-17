//
//  LoginRouter.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import Alamofire

enum LoginRouter: Router {
    case apple(AppleLoginRequestDTO)
    case google(GoogleLoginRequestDTO)
    case refresh(refreshToken: String)
    case revokeApple(auth: String)
}

extension LoginRouter {
    var method: HTTPMethod {
        switch self {
        case .apple, .google, .refresh:
            return .post
        case .revokeApple:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .apple:
            return "/auth/apple/login"
        case .google:
            return "/auth/google/login"
        case .refresh:
            return "/auth/refresh"
        case .revokeApple:
            return "/auth/delete/apple"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .apple, .google:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        
        case let .refresh(refreshToken: token):
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json"),
                HTTPHeader(name: "RefreshToken", value: "Bearer \(token)")
            ])
            
        case let .revokeApple(authToken):
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json"),
                HTTPHeader(name: "authorization-code", value: authToken)
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .apple, .google, .refresh, .revokeApple:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .apple(let appleLoginRequest):
            return requestToBody(appleLoginRequest)
        case .google(let googleLoginRequest):
            return requestToBody(googleLoginRequest)
        case .refresh, .revokeApple:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .revokeApple:
            return .url
        case .apple, .google, .refresh:
            return .json
        }
    }
}
