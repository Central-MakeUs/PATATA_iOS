//
//  PASearchBar.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI

struct PASearchBar: View {
    var realSearch: Bool
    let placeHolder: String
    var bindingText: Binding<String>?
    let onSubmit: (() -> Void)?
    let imageSubmit: (() -> Void)?
    let placeHolderColor: Color
        
    init(
        placeHolder: String,
        bindingText: Binding<String>,
        onSubmit: @escaping () -> Void,
        imageSubmit: @escaping () -> Void,
        placeHolderColor: Color = .textDisabled
    ) {
        self.placeHolder = placeHolder
        self.realSearch = true
        self.bindingText = bindingText
        self.onSubmit = onSubmit
        self.imageSubmit = imageSubmit
        self.placeHolderColor = placeHolderColor
    }
    
    init(placeHolder: String, placeHolderColor: Color = .textDisabled) {
        self.placeHolder = placeHolder
        self.realSearch = false
        self.bindingText = nil
        self.onSubmit = nil
        self.imageSubmit = nil
        self.placeHolderColor = placeHolderColor
    }
    
    var body: some View {
        paSearchBar
    }
}

extension PASearchBar {
    private var paSearchBar: some View {
        HStack {
            if realSearch, let bindingText, let onSubmit, let imageSubmit {
                TextField(
                    "search",
                    text: bindingText,
                    prompt: Text(
                        placeHolder
                    ).foregroundColor(
                        placeHolderColor
                    )
                )
                .onSubmit {
                    onSubmit()
                }
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray70)
                    .asButton {
                        imageSubmit()
                    }
                
            } else {
                Text(placeHolder)
                    .foregroundStyle(placeHolderColor)
                    .textStyle(.bodyS)
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray70)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(.gray20, lineWidth: 1)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        )
    }
}
