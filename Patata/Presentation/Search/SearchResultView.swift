//
//  SearchResultView.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI
import ComposableArchitecture

// 컨텐츠 내부 높이 맞춰서 높이가 조정되어야함
// 클릭을 하면 시트가 내려가면서 해당 텍스트를 필터 텍스트에 반영해야함
// 외부 뷰는 흐르게 보여야함
// 외부 뷰를 눌렀을때 dismiss되어야함
// 뷰 상단에 핸들이 있어야함

struct SearchResultView: View {
    
//    @Binding var spotItems: SpotItems
    @State var isPresent: Bool = false
    @State var filter: String = "거리순"
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible())
    ]
    
    var body: some View {
//        WithPerceptionTracking {
        NavigationView {
            contentView
                .navigationBarHidden(true)
                .presentBottomSheet(isPresented: $isPresent) {
                    BottomSheetItem(title: "정렬", items: ["거리순", "추천순"]) { item in
                        isPresent = false
                        filter = item
                        // 여기서 필터에 맞게 통신 아마 onChange에서 통신할듯
                    }
                }

            //        }
        }
    }
}

extension SearchResultView {
    private var contentView: some View {
        VStack {
            fakeNavBar
            
            ScrollView {
                
                filterView
                    .padding(.top, 12)
                    .padding(.horizontal, 15)
                
                spotGridView
            }
            .background(.gray10)
        }
    }
    
    private var fakeNavBar: some View {
        VStack {
            ZStack {
                HStack {
                    NavBackButton {
                        print("back")
                    }
                    .padding(.leading, 15)
                    
                    Spacer()
                }
                
                Text("검색 내용")
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
            }
            
            PASearchBar(placeHolder: "검색어")
                .padding(.horizontal, 15)
            
            Spacer()
                .frame(height: 12)
        }
    }
    
    private var filterView: some View {
        HStack(spacing: 1) {
            HStack {
                Text("스팟")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDefault)
                
                Text("6")
                    .textStyle(.captionM)
                    .foregroundStyle(.textInfo)
            }
            
            Spacer()
            
            HStack(spacing: 1) {
                Text(filter)
                    .foregroundStyle(.textInfo)
                    .textStyle(.captionM)
                    .asButton {
                        isPresent = true
                    }
                
                Image("UnderIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            .asButton {
                print("tap")
                isPresent = true
            }
        }
    }
    
    private var spotGridView: some View {
        LazyVGrid(columns: columns, spacing: 12) {
//            ForEach(items) { item in
//                CourseItemView(item: item)
//            }
            
            ForEach(0..<10) { _ in
                spotView
            }
        }
        .padding(16)
    }
    
    private var spotView: some View {
        VStack(alignment: .leading, spacing: 0) {
//            Image(item.image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: .infinity)
//                    .aspectRatio(1.0, contentMode: .fit) // Double 값으로 변경
//                    .clipped()
//                    .cornerRadius(8)
            
            Rectangle()
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 아래부터는 아이템 들어오면 데이터자리들
            Text("이촌 한강공원 철교")
                .textStyle(.subtitleS)
                .foregroundStyle(.textDefault)
                .padding(.top, 12)
            
            HStack(spacing: 8) {
                Text("12.2" + "Km")
                    .textStyle(.captionS)
                    .foregroundStyle(.textInfo)
                
                SaveCommentCountView(archiveCount: 117, commentCount: 117, imageSize: 12)
            }
            .padding(.top, 4)
        }
    }
}
