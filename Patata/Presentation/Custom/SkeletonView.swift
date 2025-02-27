//
//  SkeletonView.swift
//  Patata
//
//  Created by 김진수 on 2/27/25.
//

import SwiftUI

struct SkeletonView: View {
    
    var body: some View {
        contentView()
    }
}

extension SkeletonView {
    private func contentView() -> some View {
        VStack {
            mainImageView()
        }
    }
    
    private func mainImageView() -> some View {
        HStack {
            Rectangle()
                .foregroundStyle(.gray30)
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.leading, 10)
                .padding(.vertical, 10)
            
            spotDesView
            
            Spacer()
        }
    }
    
    private var spotDesView: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Color.gray.opacity(0.8)
                        .frame(width: 130, height: 18)
                    
                    Spacer()
                }
                
                HStack {
                    Color.gray.opacity(0.8)
                        .frame(width: 160, height: 18)
                    
                    Spacer()
                }
                
                HStack {
                    Color.gray.opacity(0.8)
                        .frame(width: 120, height: 18)
                    
                    Spacer()
                }
            }
            
            HStack(spacing: 4) {
                ForEach(0..<2) { _ in
                    Color.gray.opacity(0.8)
                        .frame(width: 30, height: 18)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
    }
}
