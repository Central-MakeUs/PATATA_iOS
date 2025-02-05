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
    case nick
}

extension LoginRouter {
    var method: HTTPMethod {
        switch self {
        case .apple, .google, .refresh:
            return .post
        case .nick:
            return .patch
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
        case .nick:
            return "/member/nickname"
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
            
        case .nick:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json"),
                HTTPHeader(name: "Authorization", value: UserDefaultsManager.accessToken)
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .apple, .google, .refresh, .nick:
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
        case .nick:
            return requestToBody(Nick(nickName: "멜론"))
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .apple, .google, .refresh, .nick:
            return .json
        }
    }
}
