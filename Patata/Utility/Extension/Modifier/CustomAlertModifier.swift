//
//  CustomAlertModifier.swift
//  Patata
//
//  Created by 김진수 on 1/31/25.
//

import SwiftUI

struct CustomAlertModifier: ViewModifier {
    
    @State private var stateSize: CGSize = .zero
    @Binding var isPresented: Bool
    
    let title: String?
    let message: String
    let cancelText: String
    let confirmText: String
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black
                    .opacity(0.1)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                CustomAlert(
                    isPresented: $isPresented,
                    title: title,
                    message: message,
                    cancelText: cancelText,
                    confirmText: confirmText,
                    onConfirm: onConfirm
                )
                .transition(.scale)
                .sizeState(size: $stateSize)
                .frame(height: stateSize.height)
            }
        }
    }
}
