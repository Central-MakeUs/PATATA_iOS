//
//  APIError.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

enum APIError: Error {
    case token(TokenError)
    case unwoned(APIResponseError)
    
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
        default:
            return nil
        }
    }
}
