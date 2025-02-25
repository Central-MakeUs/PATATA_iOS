//
//  SearchView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

// 검색 실패시 서치의 값이 달라지면 바로 searchView로 이동
// 검색 성공시에서 서치바를 누르면 searchView로 이동

struct SearchView: View {
    
    @Perception.Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color.gray10
                    .ignoresSafeArea()
                
                switch store.viewState {
                case .search:
                    contentView
                        .navigationBarBackButtonHidden(true)
                        .background(
                            Color.gray10
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        )
                        .onChange(of: store.searchText) { _ in
                            store.send(.viewEvent(.reset))
                        }
                        .onAppear {
                            store.send(.viewCycle(.onAppear))
                        }
                case .searchResult:
                    SearchResultView(store: store)
                }
            }
        }
    }
}

extension SearchView {
    private var contentView: some View {
        VStack(alignment: .center) {
            fakeNavgationBar
                .padding(.bottom, 14)
                .padding(.horizontal, 15)
            
            Spacer()
            if store.beforeViewState == .home {
                searchFailView
                    .opacity(store.searchResult ? 0 : 1)
                
                Spacer()
            }
        }
    }
    
    private var fakeNavgationBar: some View {
        HStack(spacing: 5) {
            NavBackButton {
                store.send(.viewEvent(.tappedBackButton))
            }

            PASearchBar(placeHolder: "검색어를 입력하세요", bindingText: $store.searchText.sending(\.bindingSearchText)) {
                hideKeyboard()
                store.send(.viewEvent(.searchOnSubmit))
            } imageSubmit: {
                hideKeyboard()
                store.send(.viewEvent(.searchOnSubmit))
            }
            .frame(height: 48)
        }
    }
    
    private var searchFailView: some View {
        VStack {
            Image("SearchFail")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130, height: 150)
            
            VStack(alignment: .center) {
                Text("'\(store.searchText)'에 대한")
                Text("검색 결과가 없습니다.")
            }
            .textStyle(.subtitleL)
            .foregroundStyle(.textDisabled)
        }
    }
}
