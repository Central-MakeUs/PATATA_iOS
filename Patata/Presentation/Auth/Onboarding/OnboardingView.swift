//
//  OnboardingView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    // 사용자 안내 온보딩 페이지를 앱 설치 후 최초 실행할 때만 띄우도록 하는 변수.
        // @AppStorage에 저장되어 앱 종료 후에도 유지됨.
//        @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    
    
    @Perception.Bindable var store: StoreOf<OnboardPageFeature>
    
    @State private var isShowingToast = false
    
    var body: some View {
        contentView
    }
}

extension OnboardingView {
    private var contentView: some View {
        WithPerceptionTracking {
            VStack(alignment: .center) {
                onboardingTabView
                Spacer()
                    .frame(height: 66)
                startButton
                    .padding(.horizontal, 15)
                    .padding(.bottom, 10)
            }
            .background(.blue10)
            .navigationBarBackButtonHidden(true)
        }
        
    }
    
    private var onboardingTabView: some View {
        TabView(selection: $store.currentIndex.sending(\.bindingCurrentIndex)) {
            OnboardingPageView(firstTitle: "사진 스팟,", secondTitle: "아직도 발품 팔아요?", subTitle: "놓치기 아까운 스팟, 파타타엔 다 있어요!", imageName: "Onboarding1")
                .tag(0)
            
            OnboardingPageView(firstTitle: "추천과 검색을 통해", secondTitle: "최고의 스팟을 찾아봐요!", subTitle: "놓치기 아까운 스팟, 파타타엔 다 있어요!", imageName: "Onboarding2")
                .tag(1)
            
            lastOnboardingPageView
                .tag(2)
                .onAppear {
                    print("onAppear")
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        isShowingToast = true
                    }
                }
                .onDisappear {
                    // 마지막 페이지에서 벗어날 때 토스트 숨김
                    withAnimation {
                        isShowingToast = false
                    }
                }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            CustomPageIndicator(
                numberOfPages: 3,
                currentIndex: store.currentIndex,
                viewState: .onboarding
            )
            .padding(.bottom, 30)
        }
    }
    
    private var startButton: some View {
        HStack {
            Spacer()
            
            Text(store.currentIndex == 2 ? "시작하기" : "다음")
                .textStyle(.subtitleM)
                .foregroundStyle(.white)
                .padding(.vertical, 8)
            
            Spacer()
        }
        .frame(height: 56)
        .background(.blue100)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .asButton {
            store.send(.startButtonTapped)
        }
    }
    
    private var lastOnboardingPageView: some View {
        VStack(spacing: 0) {
            VStack {
                Text("나만 아는 숨은 스팟을")
                    .textStyle(.headlineS)
                Text("등록하고 공유해봐요")
                    .textStyle(.headlineS)
            }
            
            Text("놓치기 아까운 스팟, 파타타엔 다 있어요!")
                .textStyle(.subtitleS)
                .foregroundColor(.blue50)
                .padding(.top, 8)
                .padding(.bottom, 70)
            
            
            ZStack {
                HStack {
                    Text("스팟이 등록되었습니다!")
                        .foregroundStyle(.gray70)
                        .textStyle(.subtitleM)
                    
                    Image("StarIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 50)
                .background(Color(hex: "F9FDFF"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .offset(y: isShowingToast ? -180 : -100) // 애니메이션 위치 조정
                
                Image("Onboarding3")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
            }
        }
    }
}

extension OnboardingView {
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.2)
    }
}
