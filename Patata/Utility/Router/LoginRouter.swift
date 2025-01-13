//
//  LoginRouter.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import Alamofire

enum LoginRouter: Router {
    case apple(AppleLoginRequest)
    case google(GoogleLoginRequest)
}

extension LoginRouter {
    var method: HTTPMethod {
        switch self {
        case .apple, .google:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .apple:
            return "/auth/apple/login"
        case .google:
            return "/auth/google/login"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .apple, .google:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .apple, .google:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .apple(let appleLoginRequest):
            return requestToBody(appleLoginRequest)
        case .google(let googleLoginRequest):
            return requestToBody(googleLoginRequest)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .apple, .google:
            return .json
        }
    }
}
