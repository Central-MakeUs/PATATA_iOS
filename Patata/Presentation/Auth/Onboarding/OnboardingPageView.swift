//
//  OnboardingPageView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let firstTitle: String
    let secondTitle: String
    let subTitle: String
    let imageName: String
    
    var body: some View {
        contentView
    }
}

extension OnboardingPageView {
    private var contentView: some View {
        VStack(spacing: 0) {
            titleView
            subTitleView
                .padding(.top, 8)
            
            if imageName == "Onboarding1" {
                onboardingImageView
                    .padding(.top, 80)
                    .padding(.horizontal, 50)
                    .offset(y: -20)
            } else {
                onboardingImageView
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .offset(y: -20)
            }
        }
    }
    
    private var titleView: some View {
        VStack{
            Text(firstTitle)
                .textStyle(.headlineS)
            Text(secondTitle)
                .textStyle(.headlineS)
        }
    }
    
    private var subTitleView: some View {
        Text(subTitle)
            .textStyle(.subtitleS)
            .foregroundColor(.blue50)
    }
    
    private var onboardingImageView: some View {
        if imageName == "Onboarding1" {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(width: 280, height: 340)
        } else {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(width: 300, height: 380)
        }
//            .frame(width: <#T##CGFloat?#>, height: <#T##CGFloat?#>)
    }
}
