//
//  BottomSheetModifier.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    let content: () -> SheetContent
    
    func body(content: Content) -> some View {
        ZStack {
            if isPresented {
                Color.black
                    .opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }
            
            content
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }
}
