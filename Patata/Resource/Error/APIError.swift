//
//  APIError.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

enum APIError: Error {
    case token(TokenError)
    case member(MemberError)
    case common(CommonError)
    case oauth(OAuthError)
    case search(SearchError)
    case unknown(APIResponseErrorDTO)
    
    static func getType(code: String) -> APIError? {
        switch code {
        case "TOKEN4000":
            return .token(.tokenNotExist)
        case "TOKEN4001":
            return .token(.invalidTokenFormat)
        case "TOKEN4002":
            return .token(.invalidAccessToken)
        case "TOKEN4003":
            return .token(.invalidRefreshToken)
            
        case "MEMBER4001":
            return .member(.usedNickname)
            
        case "OAUTH4003":
            return .oauth(.failApplelogin)
            
        case "COMMON200":
            return .common(.success)
        case "COMMON400":
            return .common(.invalidRequest)
            
        case "SPOT4005":
            return .search(.noData)
            
        default:
            return nil
        }
    }
}
