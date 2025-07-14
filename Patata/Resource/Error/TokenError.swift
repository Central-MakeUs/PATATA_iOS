//
//  TokenError.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation

enum TokenError: Error {
    case tokenNotExist // TOKEN4000 재로그인
    case invalidTokenFormat // TOKEN4001 재로그인
    case invalidAccessToken // TOKEN4002 이때는
    case invalidRefreshToken // TOKEN4003 재로그인
}
