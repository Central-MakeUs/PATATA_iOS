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
    let backgroundColor: Color
        
    init(
        placeHolder: String,
        bindingText: Binding<String>,
        onSubmit: @escaping () -> Void,
        imageSubmit: @escaping () -> Void,
        placeHolderColor: Color = .textDisabled,
        backgroundColor: Color
    ) {
        self.placeHolder = placeHolder
        self.realSearch = true
        self.bindingText = bindingText
        self.onSubmit = onSubmit
        self.imageSubmit = imageSubmit
        self.placeHolderColor = placeHolderColor
        self.backgroundColor = backgroundColor
    }
    
    init(placeHolder: String, placeHolderColor: Color = .textDisabled, backgroundColor: Color) {
        self.placeHolder = placeHolder
        self.realSearch = false
        self.bindingText = nil
        self.onSubmit = nil
        self.imageSubmit = nil
        self.placeHolderColor = placeHolderColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        paSearchBar
    }
}

extension PASearchBar {
    private var paSearchBar: some View {
        HStack {
            if realSearch, let bindingText, let onSubmit, let imageSubmit {
                DisablePasteTextField(
                    text: bindingText,
                    isFocused: nil,
                    placeholder: placeHolder,
                    placeholderColor: .textDisabled,
                    edge: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0),
                    keyboardType: .default,
                    onCommit: {
                        onSubmit()
                    }
                )
                
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
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.gray20, lineWidth: 1)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
    }
}
