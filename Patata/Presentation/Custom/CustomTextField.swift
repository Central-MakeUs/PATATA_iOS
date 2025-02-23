//
//  CustomTextField.swift
//  Patata
//
//  Created by 김진수 on 1/31/25.
//

import SwiftUI

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var textStyle: TextStyle
    var placeholderStyle: TextStyle
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.smartDashesType = .no
        textField.delegate = context.coordinator
        
        textField.isSecureTextEntry = false
        textField.allowsEditingTextAttributes = false
        
        // 텍스트 폰트 설정
        let textFontName: String
        switch textStyle {
        case .headlineL:
            textFontName = "Pretendard-Bold"
        case .headlineM, .headlineS,
                .subtitleL, .subtitleM, .subtitleS, .subtitleXS, .subtitleSM,
                .captionS, .headlineXS:
            textFontName = "Pretendard-SemiBold"
        case .bodyM, .bodyS, .captionM:
            textFontName = "Pretendard-Regular"
        case .bodySM:
            textFontName = "Pretendard-Medium"
        }
        
        // 플레이스홀더 폰트 설정
        let placeholderFontName: String
        switch placeholderStyle {
        case .headlineL:
            placeholderFontName = "Pretendard-Bold"
        case .headlineM, .headlineS,
                .subtitleL, .subtitleM, .subtitleS, .subtitleXS, .subtitleSM,
                .captionS, .headlineXS:
            placeholderFontName = "Pretendard-SemiBold"
        case .bodyM, .bodyS, .captionM:
            placeholderFontName = "Pretendard-Regular"
        case .bodySM:
            placeholderFontName = "Pretendard-Medium"
        }
        
        textField.font = UIFont(name: textFontName, size: textStyle.fontSize)
        
        // 플레이스홀더 설정
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(Color.textDisabled),
                .font: UIFont(name: placeholderFontName, size: placeholderStyle.fontSize) ?? .systemFont(ofSize: placeholderStyle.fontSize)
            ]
        )
        
        // 라인 높이 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = textStyle.lineHeight
        paragraphStyle.maximumLineHeight = textStyle.lineHeight
        
        textField.defaultTextAttributes.updateValue(
            paragraphStyle,
            forKey: .paragraphStyle
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ textField: CustomTextField) {
            self.parent = textField
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            textField.selectedTextRange = nil  // 선택 비활성화
            if let text = textField.text, let textRange = Range(range, in: text) {
                parent.text = text.replacingCharacters(in: textRange, with: string)
            }
            return false
        }
        
        // 컨텍스트 메뉴 비활성화
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            textField.inputAssistantItem.leadingBarButtonGroups = []
            textField.inputAssistantItem.trailingBarButtonGroups = []
            return true
        }
    }
}
