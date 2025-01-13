//
//  APIError.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

enum APIError: Error {
    case routerError(RouterError)
    case viewError(PresentationError)
    case domainError(DomainError)
    case unowned
}

enum PresentationError: Error {
    case message(String)
    // 필요한 경우 다른 presentation 관련 에러도 추가 가능
    case invalidState
    case invalidInput
}
