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
//                TextField(
//                    "search",
//                    text: bindingText,
//                    prompt: Text(
//                        placeHolder
//                    ).foregroundColor(
//                        placeHolderColor
//                    )
//                )
//                .onSubmit {
//                    onSubmit()
//                }
                
                DisablePasteTextField(
                    text: bindingText,
                    isFocused: nil, // nil로 설정하여 내부 포커스 관리를 비활성화
                    placeholder: placeHolder,  // 비워두기 - 오버레이에서 처리
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
