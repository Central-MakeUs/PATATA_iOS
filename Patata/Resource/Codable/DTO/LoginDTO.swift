//
//  LoginDTO.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

struct LoginDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: UserResult
}

struct UserResult: DTO {
    let nickName: String?
    let email: String
    let accessToken: String
    let refreshToken: String
}
