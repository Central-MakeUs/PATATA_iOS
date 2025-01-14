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
        VStack {
            titleView
            subTitleView
                .padding(.top, 5)
            onboardingImageView
                .padding(.top, 12)
                .padding(.horizontal, 16)
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
        Image(imageName)
            .resizable()
            .scaledToFit()
            .aspectRatio(1, contentMode: .fit)
    }
}
