//
//  LoginManager.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import GoogleSignIn

@MainActor
struct LoginManager {
    func googleLogin() async throws -> GIDToken {
        return try await withCheckedThrowingContinuation { continuation in
            guard let presentingViewController = (
                UIApplication.shared.connectedScenes.first as? UIWindowScene
            )?.windows.first?.rootViewController else {
                continuation.resume(throwing: LoginError.noPresentingViewController)
                return
            }
            
            GIDSignIn
                .sharedInstance
                .signIn(
                    withPresenting: presentingViewController
                ) { signInResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let result = signInResult,
                          let idToken = result.user.idToken else {
                        continuation.resume(throwing: LoginError.noIdToken)
                        return
                    }
                    
                    print(idToken.tokenString)
                    
                    continuation.resume(returning: idToken)
                }
        }
    }
}
