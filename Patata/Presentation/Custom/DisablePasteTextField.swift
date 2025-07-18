//
//  DisablePasteTextField.swift
//  Patata
//
//  Created by 김진수 on 2/25/25.
//

import Foundation
import SwiftUI

struct DisablePasteTextField: View {
    @Binding var text: String
    var isFocused: Binding<Bool>?
    
    let placeholder: String
    let placeholderColor: Color
    let edge: UIEdgeInsets
    let keyboardType: UIKeyboardType
    var isSecureTextEntry: Bool = false
    var ifLeadingEdge: CGFloat?
    let onCommit: (() -> Void)?
    
    init(
        text: Binding<String>,
        isFocused: Binding<Bool>? = nil,
        placeholder: String,
        placeholderColor: Color,
        isSecureTextEntry: Bool = false,
        edge: UIEdgeInsets,
        keyboardType: UIKeyboardType,
        ifLeadingEdge: CGFloat? = nil,
        onCommit: ( () -> Void)?
    ) {
        self._text = text
        self.isFocused = isFocused
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.edge = edge
        self.keyboardType = keyboardType
        self.ifLeadingEdge = ifLeadingEdge
        self.isSecureTextEntry = isSecureTextEntry
        self.onCommit = onCommit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DisablePasteTextFieldPrepresentable(
                text: $text,
                isFocused: isFocused,
                keyboardType: keyboardType,
                isSecureTextEntry: isSecureTextEntry,
                onCommit: onCommit
            )
            .padding(.leading, ifLeadingEdge ?? 0)
//            .fixedSize(horizontal: true, vertical: false)
        }
        .background(
            HStack {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(placeholderColor)
                        .textStyle(.bodyS)
                    Spacer()
                }
            }
        )
        .padding(EdgeInsets(top: edge.top, leading: edge.left, bottom: edge.right, trailing: edge.right))
    }
    
}

struct DisablePasteTextFieldPrepresentable: UIViewRepresentable {
    
    @Binding var text: String
    var isFocused: Binding<Bool>?
    let keyboardType: UIKeyboardType
    let isSecureTextEntry: Bool
    let onCommit: (() -> Void)?
    
    typealias UIViewType = ProtectedTextField
    
    func makeUIView(context: Context) -> ProtectedTextField {
        let textField = ProtectedTextField()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = TextStyle.subtitleS.lineHeight
        paragraphStyle.maximumLineHeight = TextStyle.subtitleS.lineHeight
        
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecureTextEntry
        textField.autocorrectionType = .no // 자동 수정 활성화 여부
        textField.autocapitalizationType = .none // 자동 대문자 활성화 여부
        let attributes: [NSAttributedString.Key: Any] = [
            .font: TextStyle.subtitleS.uiFont, 
            .paragraphStyle: paragraphStyle,
            .baselineOffset: (TextStyle.subtitleS.lineHeight - TextStyle.subtitleS.fontSize) / 2
        ]
        
        textField.defaultTextAttributes = attributes
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldTapped), for: .editingDidBegin)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }
    
    func updateUIView(_ uiView: ProtectedTextField, context: Context) {
        uiView.text = text
        
        if let isFocused = isFocused {
            if isFocused.wrappedValue, !uiView.isFirstResponder {
                DispatchQueue.main.async {
                    uiView.becomeFirstResponder()
                }
            } else if !isFocused.wrappedValue, uiView.isFirstResponder {
                DispatchQueue.main.async {
                    uiView.resignFirstResponder()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isFocused: isFocused, onCommit: onCommit)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var isFocused: Binding<Bool>?
        
        let onCommit: (() -> Void)?
        
        init(text: Binding<String>, isFocused: Binding<Bool>?, onCommit: (() -> Void)?) {
            self._text = text
            self.isFocused = isFocused
            self.onCommit = onCommit
        }

        
        @objc func textFieldTapped() {
            // 사용자가 텍스트 필드를 탭했을 때 포커스를 설정
            if let isFocused = isFocused, !isFocused.wrappedValue {
                isFocused.wrappedValue = true
            }
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit?()
            textField.resignFirstResponder()
            return true
        }
    }
}

// Custom TextField with disabling paste action
class ProtectedTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    override func buildMenu(with builder: any UIMenuBuilder) {
        if #available(iOS 17.0, *) {
            builder.remove(menu: .autoFill)
        }
        super.buildMenu(with: builder)
    }
}
