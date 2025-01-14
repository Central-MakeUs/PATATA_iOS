//
//  LoginView.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    let loginManager = LoginManager()
    let networkManager = NetworkManager()
    
    var body: some View {
        VStack {
            customAppleLoginButton
                .overlay {
                    oriAppleLoginButton
                        .blendMode(.overlay)
                }
            
            googleLoginButton
                .frame(height: 20)
                .padding(.top, 30)
        }
        .padding(.horizontal, 20)
    }
}

extension LoginView {
    private var customAppleLoginButton: some View {
        HStack {
            Spacer()
                
            Image("AppleLogo")
            Text("애플 계정으로 로그인하기")
                .foregroundStyle(.white)
            
            Spacer()
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .frame(maxWidth: .infinity)
    }
    
    private var oriAppleLoginButton: some View {
        SignInWithAppleButton { request in
            loginManager.appleRequest(request: request)
        } onCompletion: { result in
            do {
                let identityToken = try loginManager.appleLoginResult(result: result)
                
                Task {
                    let result = try await NetworkManager.shared.requestNetwork(dto: LoginDTO.self, router: LoginRouter.apple(AppleLoginRequest(identityToken: identityToken)))
                    
                    print("success", result)
                }
                
            } catch {
                print(error)
            }
        }
    }

    
    private var googleLoginButton: some View {
        GoogleSignInButton(
            scheme: .light,
            style: .wide
        ) {
            Task {
                let gIDToken = try await loginManager.googleLogin()
                let result = try await networkManager.requestNetwork(dto: LoginDTO.self, router: LoginRouter.google(GoogleLoginRequest(idToken: gIDToken.tokenString)))
                
                print("success", result)
            }
        }
//        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
