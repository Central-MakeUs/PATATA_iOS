//
//  LoginView.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    let loginManager = LoginManager()
    let networkManager = NetworkManager()
    
    var body: some View {
        GoogleSignInButton(
            scheme: .light,
            style: .wide
        ) {
            Task {
                let gIDToken = try await loginManager.googleLogin()
                let result = try await networkManager.requestNetwork(dto: GoogleLoginRequest.self, router: LoginRouter.google(GoogleLoginRequest(idToken: gIDToken.tokenString)))
            }
        }
    }
}

extension LoginView {
    
}
