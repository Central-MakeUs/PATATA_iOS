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
        tabContentView: @escaping () -> some View
    ) -> some View {
        if #available(iOS 18.0, *) {
            TabView(selection: selection) {
                Tab(
                    "홈",
                    image: tabState == .home ? "HomeActive" : "HomeInActive",
                    value: .home
                ) {
                    tabContentView()
                }
            }
            .tint(.textDefault)
        } else {
            TabView(selection: selection) {
                tabContentView()
                    .tabItem {
                        Image(tabState == .home ? "HomeActive" : "HomeInActive")
                    }
                    .tag(TabCase.home)
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
    func presentBottomSheet<SheetContent: View>(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void, content: @escaping () -> SheetContent) -> some View {
        self.modifier(BottomSheetModifier(isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}
