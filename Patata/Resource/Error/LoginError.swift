//
//  LoginError.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

enum LoginError: Error {
    case appleLoginError(AppleLoginError)
    case googleLoginError(GoogleLoginError)
}

enum AppleLoginError: Error {
    case loginFailed
    case noIdentityToken
}

enum GoogleLoginError: Error {
    case noPresentingViewController
    case noIdToken
    case noUser
    case noAccessToken
    case apiError
}
