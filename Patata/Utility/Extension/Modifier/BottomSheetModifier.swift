//
//  BottomSheetModifier.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    let sheetContent: () -> SheetContent
    
    private var sheetOffset: CGFloat {
        isPresented ? 0 : bottomSheetSize.height
    }
    
    @State private var dragOffset: CGFloat = 0
    @State var bottomSheetSize: CGSize = .zero
    
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
            
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
            
            VStack {
                Spacer()
                
                VStack {
                    Rectangle()
                        .frame(width: 50, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 8)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if dragOffset + value.translation.height > 0 {
                                        dragOffset += value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.height > 0 {
                                        isPresented = false
                                    } else {
                                        isPresented = true
                                    }
                                    dragOffset = 0
                                }
                        )
                    
                    sheetContent()
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.textDefault)
                        .padding(.top, 8)
                }
                .padding(.bottom, 30)
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .sizeState(size: $bottomSheetSize)
            .offset(y: sheetOffset + dragOffset)
            .ignoresSafeArea(edges: .bottom)
            .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
        .frame(maxWidth: .infinity)
        
    }
}
