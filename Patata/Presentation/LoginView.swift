//
//  LoginView.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        GoogleSignInButton(
            scheme: .light,
            style: .wide
        ) {
            googleLogin()
        }
    }
}

extension LoginView {
    func googleLogin() {
        guard let presentingViewController = (
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        )?.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn
            .sharedInstance
            .signIn(
                withPresenting: presentingViewController
            ) {
                signInResult,
                error in
                guard let result = signInResult else {
                    print("error")
                    return
                }
                
                guard let profile = result.user.profile else { return }
                // If sign in succeeded, display the app's main content View.
                
                let email = profile.email
                
            }
    }
}
