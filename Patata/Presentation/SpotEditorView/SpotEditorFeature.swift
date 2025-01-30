//
//  SpotEditorFeature.swift
//  Patata
//
//  Created by 김진수 on 1/30/25.
//

import Foundation
import ComposableArchitecture

// 처음 들어올때 스팟을 등록하러 왔는지 수정하러 왔는지 체크 필요 이건 처음에 모든 값이 들어오는지로 판단해야될듯
@Reducer
struct SpotEditorFeature {
    
    @ObservableState
    struct State: Equatable {
        var viewState: ViewState
        var spotEditorIsValid: Bool = false
        var categoryText: String = "카테고리를 선택해주세요"
        
        // bindingState
        var title: String = ""
        var location: String = ""
        var detail: String = ""
        var hashTag: String = ""
        var isPresent: Bool = false
    }
    
    enum ViewState {
        case add
        case edit
    }
    
    enum Action {
        case textValidation(TextValidation)
        case viewEvent(ViewEvent)
        
        // bindingAction
        case bindingTitle(String)
        case bindingLocation(String)
        case bindingDetail(String)
        case bindingHashTag(String)
        case bindingPresent(Bool)
    }
    
    enum TextValidation {
        case titleValidation(String)
        case detilValidation(String)
    }
    
    enum ViewEvent {
        case tappedBottomSheet(String)
        case openBottomSheet(Bool)
        case closeBottomSheet(Bool)
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotEditorFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.tappedBottomSheet(category)):
                state.categoryText = category
                
            case let .viewEvent(.openBottomSheet(isPresent)):
                state.isPresent = isPresent
                
            case let .viewEvent(.closeBottomSheet(isPresent)):
                state.isPresent = isPresent
                
            case let .textValidation(.titleValidation(titleText)):
                let limitedText = String(titleText.prefix(15))
                
                // 새로운 입력이 빈 스페이스로 시작하는 경우 방지
                if limitedText.first == " " {
                    state.title = ""
                    return .none
                }
                
                // 연속 스페이스 방지
                if limitedText.contains("  ") {
                    state.title = limitedText.replacingOccurrences(of: "  ", with: " ")
                    return .none
                }
                
                // 현재 상태의 마지막 문자가 스페이스이고, 새로운 입력도 스페이스로 시작하는 경우 방지
                if let lastChar = state.title.last,
                   lastChar == " ",
                   limitedText.last == " " {
                    state.title = state.title
                    return .none
                }
                
                state.title = limitedText
                
            case let .textValidation(.detilValidation(detail)):
                let totalLength = detail.reduce(0) { count, char in
                    if char == "\n" {
                        return count + 1  // 엔터를 1자로 계산
                    }
                    return count + 1
                }
                
                // 300자 제한 적용
                if totalLength > 300 {
                    state.detail = state.detail  // 현재 상태 유지
                    return .none
                }
                
                // 연속 스페이스 방지
                if detail.contains("  ") {
                    state.detail = state.detail
                    return .none
                }
                
                // 첫 글자 공백 방지
                if detail.first == " " {
                    state.detail = ""
                    return .none
                }
                    
                state.detail = detail
                
            case let .bindingTitle(title):
                state.title = title
                
            case let .bindingLocation(location):
                state.location = location
                
            case let .bindingDetail(detail):
                state.detail = detail
                
            case let .bindingHashTag(hashTag):
                state.hashTag = hashTag
                
            case let .bindingPresent(isPresent):
                state.isPresent = isPresent
                
            default:
                break
            }
            
            return .none
        }
    }
}
