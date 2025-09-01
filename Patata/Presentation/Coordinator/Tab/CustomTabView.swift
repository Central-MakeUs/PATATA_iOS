//
//  CustomTabView.swift
//  Patata
//
//  Created by 김진수 on 9/1/25.
//

import SwiftUI

private struct TabBarContent: View {
    let selected: TabCase
    let onSelect: ((TabCase) -> Void)?
    var body: some View {
        contentView
            .background(Color.white)
            .ignoresSafeArea(edges: .bottom)
            .shadow(color: .shadowColor, radius: 20, y: -6)
            .allowsHitTesting(onSelect != nil)
    }
}

extension TabBarContent {
    private var contentView: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach(TabCase.order, id: \.self) { tag in
                    let a = tag.asset
                    
                    VStack(spacing: 2) {
                        Image(selected == tag ? a.active : a.inactive)
                        Text(a.title)
                            .font(.pretendard(.regular, size: 12))
                    }
                    .foregroundStyle(
                        selected == tag ? Color.navy100 : Color.gray50
                    )
                    .frame(maxWidth: .infinity)
                    .contentShape(
                        Rectangle()
                    )
                    .onTapGesture { onSelect?(tag) }
                }
            }
        }
    }
}

struct TabBarView: View {
    @Binding var selection: TabCase
    var interactive: Bool = true
    
    var body: some View {
        TabBarContent(
            selected: selection,
            onSelect: interactive ? { selection = $0 } : nil
        )
        .allowsHitTesting(interactive)
    }
}

struct CustomTabView: View {
    @Binding var selectedCase: TabCase
    var body: some View {
        TabBarView(selection: $selectedCase, interactive: true)   // 진짜
    }
}

struct FakeTabView: View {
    var selectedCase: TabCase
    var body: some View {
        TabBarView(selection: .constant(selectedCase), interactive: false)  // 가짜
    }
}
