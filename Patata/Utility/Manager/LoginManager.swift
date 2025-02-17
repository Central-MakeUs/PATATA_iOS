//
//  LoginManager.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import ComposableArchitecture

//@MainActor
//final class LoginManager: @unchecked Sendable {
//    
//    private init() { }
//    
//    func appleRequest(request: ASAuthorizationAppleIDRequest) {
//        request.requestedScopes = [.email, .fullName]
//    }
//    
//    func appleLoginResult(result: Result<ASAuthorization, any Error>) throws(LoginError) -> String {
//        switch result {
//        case .success(let authResults):
//            switch authResults.credential{
//            case let appleIDCredential as ASAuthorizationAppleIDCredential:
//                // 계정 정보 가져오기
//                let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
//                
//                if let identityToken {
//                    return identityToken
//                } else {
//                    print("fail")
//                    throw LoginError.appleLoginError(.noIdentityToken)
//                }
//                
//            default:
//                throw LoginError.appleLoginError(.loginFailed)
//            }
//            
//        case .failure(let error):
//            print(error.localizedDescription)
//            print("error")
//            throw LoginError.appleLoginError(.loginFailed)
//        }
//    }
//    
//    func googleLogin() async throws -> GIDToken {
//        return try await withCheckedThrowingContinuation { continuation in
//            guard let presentingViewController = (
//                UIApplication.shared.connectedScenes.first as? UIWindowScene
//            )?.windows.first?.rootViewController else {
//                continuation.resume(throwing: LoginError.googleLoginError(.noPresentingViewController))
//                return
//            }
//            
//            GIDSignIn
//                .sharedInstance
//                .signIn(
//                    withPresenting: presentingViewController
//                ) { signInResult, error in
//                    if let error = error {
//                        continuation.resume(throwing: error)
//                        return
//                    }
//                    
//                    guard let result = signInResult,
//                          let idToken = result.user.idToken else {
//                        continuation.resume(throwing: LoginError.googleLoginError(.noIdToken))
//                        return
//                    }
//                    
//                    continuation.resume(returning: idToken)
//                }
//        }
//    }
//}
//
//extension LoginManager {
//    static let shared = LoginManager()
//}
//
//extension LoginManager: DependencyKey {
//    static let liveValue: LoginManager = LoginManager.shared
//}
//
//extension DependencyValues {
//    var loginManager: LoginManager {
//        get { self[LoginManager.self] }
//        set { self[LoginManager.self] = newValue }
//    }
//}

final class LoginManager: @unchecked Sendable  {
    
    @MainActor
    func getASAuthorization() async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            
            let request = ASAuthorizationAppleIDProvider()
                .createRequest()
            
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            let delegate = AppleSignProtocol(continuation: continuation)
            
            controller.delegate = delegate
            
            controller.performRequests()
            AppleSignInDelegateStore.shared.delegate = delegate
        }
    }
    
    func handleAuthorization(
        _ authorization: ASAuthorization
    ) -> (auth: String?, id: String?) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var idToken: String? = nil
            var authToken: String? = nil
            
            // 사용자 ID
            let userID = appleIDCredential.user
            print("User ID: \(userID)")

            // 사용자 이메일 (최초 로그인 시만)
            let email = appleIDCredential.email
            print("Email: \(email ?? "No Email")")
            
            UserDefaultsManager.email = email ?? ""

            // 사용자 이름 (최초 로그인 시만)
            if let fullName = appleIDCredential.fullName {
                let givenName = fullName.givenName ?? ""
                let familyName = fullName.familyName ?? ""
                print("Full Name: \(givenName) \(familyName)")
            }
            
            // 인증 코드 (서버 검증에 사용)
            let authorizationCode = appleIDCredential.authorizationCode
            print("Authorization Code: \(String(data: authorizationCode ?? Data(), encoding: .utf8) ?? "")")
            
            // ID Token (서버 검증에 사용)
            let identityToken = appleIDCredential.identityToken
            print("Identity Token: \(String(data: identityToken ?? Data(), encoding: .utf8) ?? "")")
            
            if let authorizationCode {
                let auth = String(data: authorizationCode, encoding: .utf8)
                authToken = auth
            }
            if let identityToken {
                let id = String(data: identityToken, encoding: .utf8)
                idToken = id
            }
            return (authToken, idToken)
        }
        return (nil, nil)
    }
    
    @MainActor
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
                    
                    continuation.resume(returning: idToken)
                }
        }
    }
}

final class AppleSignInDelegateStore {
    static let shared = AppleSignInDelegateStore()
    var delegate: AppleSignProtocol?
}

extension LoginManager: DependencyKey {
    static let liveValue: LoginManager = LoginManager()
}

extension DependencyValues {
    var loginManager: LoginManager {
        get { self[LoginManager.self] }
        set { self[LoginManager.self] = newValue }
    }
}

final class AppleSignProtocol: NSObject, ASAuthorizationControllerDelegate {

    let continuation: CheckedContinuation<ASAuthorization, Error>

    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}
