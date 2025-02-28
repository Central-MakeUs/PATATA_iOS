//
//  BottomSheetModifier.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    let sheetContent: () -> SheetContent
    let mapBottomView: (() -> SheetContent)?
    let onDismiss: (() -> Void)?
    let isMap: Bool
    
    private var sheetOffset: CGFloat {
        isPresented ? (isFullSheet ? (isFull ? 0 : UIScreen.main.bounds.height / 2) : 0) : bottomSheetSize.height
    }
    
    @State var dragOffset: CGFloat = 0
    @State var bottomSheetSize: CGSize = .zero
    @State var isFull: Bool = false // sheet의 사이즈
    @State var isFullSheet: Bool
    
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
            
            if isPresented {
                
                if isFull {
                    Color.white
                        .ignoresSafeArea()
                } else if !isMap {
                    Color.black
                        .opacity(0.1)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if let onDismiss {
                                onDismiss()
                            }
                            withAnimation {
                                isFull = false
                                isPresented = false
                            }
                        }
                        .transition(.opacity)
                }
            }
            
            bottomSheetItem
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    private var bottomSheetItem: some View {
        VStack {
            Spacer()
            
            Group {
                if let mapBottomView {
                    mapBottomView()
                }
                
                VStack {
                    if isFullSheet {
                        if !isFull {
                            Rectangle()
                                .frame(width: 50, height: 4)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.vertical, 8)
                                .opacity(isFull ? 0 : 1)
                        }
                        
                        sheetContent()
                            .environment(\.isScrollEnabled, isFull)
                    } else if !isMap {
                        VStack {
                            Rectangle()
                                .frame(width: 50, height: 4)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 8)
                            
                            sheetContent()
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(.textDefault)
                                .padding(.top, 8)
                                .padding(.bottom, 30)
                        }
                    } else {
                        VStack {
                            Rectangle()
                                .frame(width: 50, height: 4)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                                .contentShape(Rectangle())
                            
                            sheetContent()
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(.textDefault)
                                .padding(.top, 8)
                                .padding(.bottom, 30)
                        }
                    }
                }
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .shadow(color: isMap ? .shadowColor.opacity(0.15) : .clear, radius: 8)
        }
        .frame(maxWidth: .infinity)
        .sizeState(size: $bottomSheetSize)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .offset(y: sheetOffset + dragOffset)
        .ignoresSafeArea(edges: .bottom)
        .gesture(
            DragGesture(minimumDistance: isFull ? .infinity : 0)
                .onChanged { value in
                    if isFullSheet && !isMap {
                        if abs(value.translation.height) > abs(value.translation.width) {
                            dragOffset = value.translation.height
                        }
                    } else {
                        if dragOffset + value.translation.height > 0 {
                            dragOffset = value.translation.height
                        }
                    }
                }
                .onEnded { value in
                    withAnimation(.easeInOut(duration: 0.25)) {  // 여기에 animation 추가
                            if isFullSheet {
                                if abs(value.translation.height) > abs(value.translation.width) {
                                    if value.translation.height <= -150 {
                                        isFull = true
                                    } else if value.translation.height > 10 {
                                        isPresented = false
                                    }
                                }
                            } else {
                                if value.translation.height > 0 {
                                    isPresented = false
                                    
                                    if isMap {
                                        if let onDismiss {
                                            onDismiss()
                                        }
                                    }
                                } else {
                                    isPresented = true
                                }
                            }
                            dragOffset = 0  // animation block 안에서 실행되도록
                        }
                }
        )
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .animation(.easeInOut(duration: 0.25), value: isFull)
        .onChange(of: isPresented) { newValue in
            if !newValue {
                isFull = false
            }
        }
    }
}

private struct isScrollEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isScrollEnabled: Bool {
        get { self[isScrollEnabledKey.self] }
        set { self[isScrollEnabledKey.self] = newValue }
    }
}

