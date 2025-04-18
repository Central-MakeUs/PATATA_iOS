//
//  LoginView.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import ComposableArchitecture

struct LoginView: View {

    @Perception.Bindable var store: StoreOf<LoginFeature>
    
    @State private var scale: CGFloat = 1.0
    @State private var imageOffset: CGFloat = 0
    @State private var isImageVisible: Bool = false
    @State private var timer: Timer?
    @State private var barOpacity: CGFloat = 1
    @State private var sideValid: Bool = false
    @State private var sizeState: CGSize = .zero
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color.blue20
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Image("Polaroid")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .offset(y: imageOffset)
                            .zIndex(2)
                            .opacity(isImageVisible ? 1 : 0)
                        
                            Color.blue20
                                .frame(width: 220, height: 220)
                                .zIndex(3)
                            
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(width: 235, height: 235)
                            
                            Rectangle()
                                .aspectRatio(10, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(.horizontal, 90)
                                .sizeState(size: $sizeState)
                                .scaleEffect(x: scale, y: scale, anchor: .top)
                        }
                        .zIndex(1)
                        
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(width: 235, height: 235)
                            
                            Rectangle()
                                .aspectRatio(10, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(.horizontal, 90)
                                .sizeState(size: $sizeState)
                                .opacity(barOpacity)
                                .scaleEffect(x: scale, y: scale, anchor: .top)
                        }
                        .zIndex(3)
                        
                        Image("PatataMain")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 100)
                            .padding(.top, 70)
                            .zIndex(6)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        customAppleLoginButton
                            .padding(.top, 40)
                            .asButton {
                                store.send(.viewEvent(.tappedAppleLogin))
                            }
                        
                        customGoogleLoginButton
                            .asButton {
                                store.send(.viewEvent(.tappedGoogleLogin))
                            }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 25)
                    .background(.blue20)
                }
            }
            .customAlert(isPresented: $store.isPresent.sending(\.bindingIsPresent), message: store.errorMSG, onConfirm: {
                store.send(.viewEvent(.dismiss))
            })
            .navigationBarBackButtonHidden()
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
        }
    }
}

extension LoginView {
    private var customAppleLoginButton: some View {
        HStack {
            Spacer()
                
            Image("Apple Logo")
            Text("애플 계정으로 로그인하기")
                .textStyle(.subtitleM)
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 50))
    }
    
    private var customGoogleLoginButton: some View {
        HStack {
            Spacer()
            
            Image("GoogleLogo")
            Text("구글 계정으로 로그인하기")
                .textStyle(.subtitleM)
                .foregroundStyle(.textDefault)
            
            Spacer()
        }
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 50))
    }
    
    private var oriGoogleLoginButton: some View {
        
        
        GoogleSignInButton(
            scheme: .light,
            style: .wide
        ) {
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 50))
//        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension LoginView {
    func startAnimation() {
            timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                animate()
            }
            timer?.fire() // 즉시 첫 애니메이션 시작
        }
        
        func stopAnimation() {
            timer?.invalidate()
            timer = nil
        }
    
    func animate() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isImageVisible = true
            withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                sideValid = true
                withAnimation(.easeInOut(duration: 0.5)) {
                    imageOffset = 200
                    barOpacity = 0.45
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    sideValid = false
                    
                    withAnimation(.spring(response: 0.7)) {
                        barOpacity = 1
                        imageOffset = 600
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isImageVisible = false
                        imageOffset = 0
                    }
                }
            }
        }
    }
}

