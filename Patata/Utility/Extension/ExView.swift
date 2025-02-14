//
//  ExView.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineHeight - style.fontSize)
    }
}

extension View {
    func asButton(action: @escaping () -> Void ) -> some View {
        modifier(ButtonModifier(action: action))
    }
}

extension View {
    @ViewBuilder
    func customTabView(
        selection: Binding<TabCase>,
        tabState: TabCase,
        tabHomeContentView: @escaping () -> some View,
        tabMapContentView: @escaping () -> some View
    ) -> some View {
        if #available(iOS 18.0, *) {
            TabView(selection: selection) {
                Tab(
                    "홈",
                    image: tabState == .home ? "HomeActive" : "HomeInActive",
                    value: .home
                ) {
                    tabHomeContentView()
                }
                
                Tab(
                    "내주변",
                    image: tabState == .map ? "SpotActive" : "SpotInActive",
                    value: .map
                ) {
                    tabMapContentView()
                }
            }
            .tint(.textDefault)
        } else {
            TabView(selection: selection) {
                tabHomeContentView()
                    .tabItem {
                        Image(tabState == .home ? "HomeActive" : "HomeInActive")
                    }
                    .tag(TabCase.home)
                tabMapContentView()
                    .tabItem {
                        Image(tabState == .map ?  "SpotActive" : "SpotInActive")
                    }
                    .tag(TabCase.map)
            }
        }
    }
    
    @ViewBuilder
    func hideTabBar(_ isHidden: Bool) -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarVisibility(
                isHidden ? .hidden : .visible,
                for: .tabBar
            )
        } else {
            self.toolbar(
                isHidden ? .hidden : .visible,
                for: .tabBar
            )
        }
    }
}

extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

extension View {
    func presentBottomSheet<SheetContent: View>(isPresented: Binding<Bool>, isFullSheet: Bool = false, isMap: Bool = false, mapBottomView: (() -> SheetContent)? = nil, content: @escaping () -> SheetContent, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(BottomSheetModifier(sheetContent: content, mapBottomView: mapBottomView, onDismiss: onDismiss, isMap: isMap, isFullSheet: isFullSheet, isPresented: isPresented))
    }
}

extension View {
    func sizeState(size: Binding<CGSize>) -> some View {
        self.modifier(SizeModifier(size: size))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String,
        cancelText: String = "취소",
        confirmText: String = "확인",
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(CustomAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            cancelText: cancelText,
            confirmText: confirmText,
            onConfirm: onConfirm
        ))
    }
}

extension View {
    func limitText(_ text: String, to maxLength: Int) -> some View {
        let limitedString = text.count <= maxLength
            ? text
            : String(text.prefix(maxLength)) + "..."
            
        return Text(limitedString)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
