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
}

extension LoginRouter {
    var method: HTTPMethod {
        switch self {
        case .apple, .google, .refresh:
            return .post
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
                HTTPHeader(name: "RefreshToken", value: token)
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .apple, .google, .refresh:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .apple(let appleLoginRequest):
            return requestToBody(appleLoginRequest)
        case .google(let googleLoginRequest):
            return requestToBody(googleLoginRequest)
        case .refresh:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .apple, .google, .refresh:
            return .json
        }
    }
}
