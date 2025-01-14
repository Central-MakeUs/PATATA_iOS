//
//  LoginManager.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

@MainActor
struct LoginManager {
    func appleRequest(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
    }
    
    func appleLoginResult(result: Result<ASAuthorization, any Error>) throws(LoginError) -> String {
        switch result {
        case .success(let authResults):
            switch authResults.credential{
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                // 계정 정보 가져오기
                let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
                
                if let identityToken {
                    return identityToken
                } else {
                    print("fail")
                    throw LoginError.appleLoginError(.noIdentityToken)
                }
                
            default:
                throw LoginError.appleLoginError(.loginFailed)
            }
            
        case .failure(let error):
            print(error.localizedDescription)
            print("error")
            throw LoginError.appleLoginError(.loginFailed)
        }
    }
    
    func googleLogin() async throws -> GIDToken {
        return try await withCheckedThrowingContinuation { continuation in
            guard let presentingViewController = (
                UIApplication.shared.connectedScenes.first as? UIWindowScene
            )?.windows.first?.rootViewController else {
                continuation.resume(throwing: LoginError.googleLoginError(.noPresentingViewController))
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
                        continuation.resume(throwing: LoginError.googleLoginError(.noIdToken))
                        return
                    }
                    
                    print(idToken.tokenString)
                    
                    continuation.resume(returning: idToken)
                }
        }
    }
}
