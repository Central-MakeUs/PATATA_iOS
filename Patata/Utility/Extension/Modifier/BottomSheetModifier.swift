//
//  BottomSheetModifier.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI
// map일때는 sheetOffset대로 가고(offset)
// 근데 true일 때는 0이 아닌 화면의 절반만 등장
// 위로 드래그시 전체화면

// 이중으로 드래그 해야될때
// 최상단에 offset을 감지하는 친구를 등록을 하고
// 유저가 정한 pretend중 제일 큰 범위에 도달했을때만 아래를 가능하게 해주고 그게 아니라면 오직 시트 수직 드래그
// 이 친구와 일정범위 가까운 곳을 터치할땐 시트 드래그를 우선순위 그 이외에 곳이라면 아이템 드래그 허용

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    let sheetContent: () -> SheetContent
    var isFullSheet: Bool
    
    private var sheetOffset: CGFloat {
        isPresented ? (isFullSheet ? (isFull ? 0 : UIScreen.main.bounds.height / 2) : 0) : bottomSheetSize.height
    }
    
    @State var dragOffset: CGFloat = 0
    @State var bottomSheetSize: CGSize = .zero
    @State var isFull: Bool = false // sheet의 사이즈
    
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
                
                if isFullSheet {
                    sheetContent()
                        .environment(\.scrollIsValid, isFull)
                } else {
                    Rectangle()
                        .frame(width: 50, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 8)
                    
                    sheetContent()
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.textDefault)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity)
            .sizeState(size: $bottomSheetSize)
            .background(.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .offset(y: sheetOffset + dragOffset)
            .ignoresSafeArea(edges: .bottom)
            .onAppear(perform: {
                print(sheetOffset + dragOffset)
            })
            .simultaneousGesture(
                DragGesture(minimumDistance: isFull ? .infinity : 0)
                    .onChanged { value in
                        if abs(value.translation.height) > abs(value.translation.width) {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if isFullSheet {
                            if abs(value.translation.height) > abs(value.translation.width) {
                                if -value.translation.height >= 150 {
                                    isFull = true
                                } else {
                                    isFull = false
                                }
                            }
                        } else {
                            if value.translation.height > 0 {
                                isPresented = false
                            } else {
                                isPresented = true
                            }
                        }
                        dragOffset = 0
                    }
            )
            .animation(.easeInOut(duration: 0.25), value: isPresented)
            .animation(.easeInOut(duration: 0.25), value: isFull)
                
//            VStack {
//                Spacer()
//                
//                VStack {
//                    Rectangle()
//                        .frame(width: 50, height: 4)
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                        .padding(.top, 8)
//                    
//                    sheetContent()
//                        .fixedSize(horizontal: false, vertical: true)
//                        .foregroundStyle(.textDefault)
//                        .padding(.top, 8)
//                }
//                .padding(.bottom, 30)
//                .background(.white)
//                .cornerRadius(20, corners: [.topLeft, .topRight])
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            dragOffset += value.translation.height
//                        }
//                        .onEnded { value in
//
//                            dragOffset = 0
//                        }
//                )
//            }
//            .sizeState(size: $bottomSheetSize)
//            .offset(y: sheetOffset + dragOffset)
//            .ignoresSafeArea(edges: .bottom)
//            .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
        .frame(maxWidth: .infinity)
        
    }
}

private struct ScrollIsValidKey: EnvironmentKey {
    static let defaultValue: Bool = false  // 기본값 설정
}
// Environment Values Extension
extension EnvironmentValues {
    var scrollIsValid: Bool {
        get { self[ScrollIsValidKey.self] }
        set { self[ScrollIsValidKey.self] = newValue }
    }
}

// View Extension
extension View {
    func scrollIsValidEnvironment(_ value: Bool) -> some View {
        environment(\.scrollIsValid, value)
    }
}
