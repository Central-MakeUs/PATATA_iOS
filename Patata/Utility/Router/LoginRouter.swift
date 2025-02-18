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
    case revokeGoogle(accessToken: String)
}

extension LoginRouter {
    var method: HTTPMethod {
        switch self {
        case .apple, .google, .refresh:
            return .post
        case .revokeApple, .revokeGoogle:
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
        case .revokeGoogle:
            return "/auth/delete/google"
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
            
        case let .revokeGoogle(accessToken):
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json"),
                HTTPHeader(name: "google-accessToken", value: accessToken)
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .apple, .google, .refresh, .revokeApple, .revokeGoogle:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .apple(let appleLoginRequest):
            return requestToBody(appleLoginRequest)
        case .google(let googleLoginRequest):
            return requestToBody(googleLoginRequest)
        case .refresh, .revokeApple, .revokeGoogle:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .revokeApple, .revokeGoogle:
            return .url
        case .apple, .google, .refresh:
            return .json
        }
    }
}
