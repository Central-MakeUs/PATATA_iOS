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
    
    @State private var currentIndex = 0
    @Perception.Bindable var store: StoreOf<OnboardPageFeature>
    
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
            .navigationBarBackButtonHidden(true)
        }
        
    }
    
    private var onboardingTabView: some View {
        TabView(selection: $currentIndex) {
            OnboardingPageView(firstTitle: "사진 스팟,", secondTitle: "아직도 발품 팔아요?", subTitle: "놓치기 아까운 스팟, 파타타엔 다 있어요!", imageName: "Onboarding1")
                .tag(0)
            
            OnboardingPageView(firstTitle: "추천과 검색을 통해", secondTitle: "최고의 스팟을 찾아봐요!", subTitle: "놓치기 아까운 스팟, 파타타엔 다 있어요!", imageName: "Onboarding2")
                .tag(1)
            
            OnboardingPageView(firstTitle: "나만 아는 숨은 스팟을", secondTitle: "등록하고 공유해봐요", subTitle: "놓치기 아까운 스팟, 파타타엔 다 있어요!", imageName: "Onboarding3")
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .onAppear {
            setupAppearance()
        }
    }
    
    private var startButton: some View {
        HStack {
            Spacer()
            
            Text("시작하기")
                .textStyle(.subtitleM)
                .foregroundStyle(.white)
                .padding(.vertical, 8)
            
            Spacer()
        }
        .frame(height: 56)
        .background(.blue100)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        
    }
}

extension OnboardingView {
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.2)
    }
}
