//
//  SearchView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    
    @Perception.Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden(true)
                .background(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                        }
                )
        }
    }
}

extension SearchView {
    private var contentView: some View {
        VStack(alignment: .center) {
            fakeNavgationBar
                .padding(.horizontal, 15)
            
            Spacer()
            
            searchFailView
                .opacity(store.searchResult ? 0 : 1)
            
            Spacer()
        }
    }
    
    private var fakeNavgationBar: some View {
        HStack(spacing: 5) {
            backButton

            PASearchBar(placeHolder: "검색어를 입력하세요", bindingText: $store.searchText.sending(\.bindingSearchText)) {
                hideKeyboard()
                store.send(.viewEvent(.searchOnSubmit))
            } imageSubmit: {
                hideKeyboard()
                store.send(.viewEvent(.searchOnSubmit))
            }

        }
    }
    
    private var backButton: some View {
        Image("PreviousActive")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .asButton {
                store.send(.viewEvent(.tappedBackButton))
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
