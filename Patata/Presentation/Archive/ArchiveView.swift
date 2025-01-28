//
//  ArchiveView.swift
//  Patata
//
//  Created by 김진수 on 1/28/25.
//

import SwiftUI

// 체크가 될때 체크된 스팟들을 담아서 서버에 보내야됨

struct ArchiveView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible())
    ]
    
    @State private var chooseIsValid: Bool = false
    @State private var checkSpots: Bool = false
    
    var body: some View {
        contentView
    }
}

extension ArchiveView {
    private var contentView: some View {
        VStack {
            fakeNavBar
            
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<8) { _ in
                        archiveItem()
                    }
                }
            }
        }
    }
}

extension ArchiveView {
    private var fakeNavBar: some View {
        ZStack {
            
            Text("아카이브")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                Spacer()
                
                Text(chooseIsValid ? "삭제" : "선택")
                    .padding(.trailing, 15)
                    .textStyle(.subtitleM)
                    .foregroundStyle(chooseIsValid ? .blue100 : .textDefault)
                    .asButton {
                        chooseIsValid.toggle()
                    }
            }
        }
    }
    
    private func archiveItem() -> some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                if !checkSpots {
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.gray, lineWidth: 1)
                        )
                        .frame(width: 24, height: 24)
                        .opacity(chooseIsValid ? 1 : 0)
                        .padding(.trailing, 14)
                        .padding(.top, 14)
                        .onTapGesture {
                            checkSpots = true
                        }
                        
                } else {
                    Image("CircleCheck")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 14)
                        .padding(.top, 14)
                        .onTapGesture {
                            checkSpots = false
                        }
                }
            }
    }
}
