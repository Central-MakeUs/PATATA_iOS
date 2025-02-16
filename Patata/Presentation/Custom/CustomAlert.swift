//
//  CustomAlert.swift
//  Patata
//
//  Created by 김진수 on 1/31/25.
//

import SwiftUI

struct CustomAlert: View {
    
    let title: String?
    let message: String
    let cancelText: String
    let confirmText: String
    let onCancle: (() -> Void)?
    let onConfirm: () -> Void
    
    @Binding var isPresented: Bool
    
    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String,
        cancelText: String = "취소",
        confirmText: String = "확인",
        onCancle: (() -> Void)? = nil,
        onConfirm: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.cancelText = cancelText
        self.confirmText = confirmText
        self.onCancle = onCancle
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        contentView
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 40)
    }
}

extension CustomAlert {
    private var contentView: some View {
        VStack(spacing: 0) {
            titleCommentView
                .padding(.vertical, 30)
                .padding(.horizontal, 4)
            
            Divider()
                .background(.gray30)
            
            buttonView
        }
    }
    
    private var titleCommentView: some View {
        VStack(spacing: title != nil ? 12 : 0) {
            if let title = title {
                Text(title)
                    .textStyle(.subtitleM)
                    .foregroundColor(.textDefault)
            }
            
            Text(message)
                .textStyle(.bodyS)
                .foregroundStyle(title == nil ? .textDefault : .textDisabled)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var buttonView: some View {
        HStack(spacing: 0) {
            HStack {
                Spacer()
                
                Text(cancelText)
                    .foregroundStyle(.textInfo)
                    .textStyle(.subtitleS)
                
                Spacer()
            }
            .padding(.vertical, 14)
            .asButton {
                isPresented = false
                onCancle?()
            }
            
            Divider()
                .background(.gray30)
            
            // 확인 버튼
            HStack {
                Spacer()
                
                Text(confirmText)
                    .foregroundStyle(confirmText == "설정으로 이동" ? .textDefault : .red100)
                    .textStyle(.subtitleS)
                    .asButton {
                        onConfirm()
                        isPresented = false
                    }
                
                Spacer()
            }
            .padding(.vertical, 14)
        }
    }
}
