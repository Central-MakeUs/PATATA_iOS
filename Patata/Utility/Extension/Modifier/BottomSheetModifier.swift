//
//  BottomSheetModifier.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI

struct BottomSheetModifier<TopContent: View, SheetContent: View, OverlayContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    
    let isMap: Bool
    let topContent: (() -> TopContent)?
    let sheetContent: () -> SheetContent
    let overlayContent: (() -> OverlayContent)?
    let dismiss: (() -> Void)?
    
    init(
        isPresented: Binding<Bool>,
        isMap: Bool,
        dismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent,
        overlayContent: (() -> OverlayContent)? = nil,
        topContent: (() -> TopContent)? = nil
    ) {
        self._isPresented = isPresented
        self.isMap = isMap
        self.dismiss = dismiss
        self.sheetContent = content
        self.overlayContent = overlayContent
        self.topContent = topContent
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if isPresented {
                
                if !isMap {
                    backgroundView
                }
                
                VStack {
                    if !isMap {
                        Rectangle()
                            .frame(width: 50, height: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 8)
                    }
                    
                    bottomView
                    
                }
                .background {
                    if !isMap {
                        Rectangle()
                            .fill(Color.white)
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                            .ignoresSafeArea(edges: .bottom)
                    }
                }
            }
        }
    }
}

extension BottomSheetModifier {
    private var backgroundView: some View {
        Color.black
            .opacity(0.5)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation {
                    isPresented = false
                    dismiss?()
                }
            }
            .transition(.opacity)
    }
    
    private var bottomView: some View {
        VStack {
            if let topContent = topContent {
                topContent()
            }
            
            sheetContent()
                .contentShape(Rectangle())
                .transition(.move(edge: .bottom))
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 50 {
                                dismiss?()
                                
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isPresented = false
                                    dragOffset = 0
                                }
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .background {
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(edges: .bottom)
                }
                .overlay(alignment: .topTrailing) {
                    if let overlayContent = overlayContent {
                        overlayContent()
                            .background(
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 44)
                            )
                            .padding(.top, 30)
                            .padding(.trailing, 15)
                    }
                }
                .offset(y: dragOffset)
        }
    }
}
