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
        var showPermissionAlert: Bool = false
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
        case bindingPermission(Bool)
    }
    
    enum TextValidation {
        case titleValidation(String)
        case locationValidation(String)
        case categoryValidtaion(String)
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
                let pattern = "[^a-zA-Z0-9가-힣\\s]"
                
                if limitedText.first == " " {
                    state.title = ""
                    return .none
                }
                
                
                if limitedText.contains("  ") {
                    state.title = limitedText.replacingOccurrences(of: "  ", with: " ")
                    validateEditorState(&state)
                    return .none
                }
                
                
                if let lastChar = state.title.last,
                   lastChar == " ",
                   limitedText.last == " " {
                    state.title = state.title
                    validateEditorState(&state)
                    return .none
                }
                
                guard let regex = try? NSRegularExpression(pattern: pattern) else {
                    state.title = limitedText
                    validateEditorState(&state)
                    return .none
                }
                
                let range = NSRange(location: 0, length: limitedText.utf16.count)
                let filteredText = regex.stringByReplacingMatches(
                    in: limitedText,
                    range: range,
                    withTemplate: ""
                )

                state.title = filteredText
                
                validateEditorState(&state)
                
            case let .textValidation(.locationValidation(locationText)):
                let pattern = "[^a-zA-Z0-9가-힣\\s-]"
                    
                guard let regex = try? NSRegularExpression(pattern: pattern) else {
                    state.location = state.location
                    return .none
                }
                
                let range = NSRange(location: 0, length: locationText.utf16.count)
                let filteredText = regex.stringByReplacingMatches(
                    in: locationText,
                    range: range,
                    withTemplate: ""
                )
                
                state.location = filteredText
                
                validateEditorState(&state)
                
            case let .textValidation(.detilValidation(detail)):
                let totalLength = detail.reduce(0) { count, char in
                    if char == "\n" {
                        return count + 1
                    }
                    return count + 1
                }
                
                if totalLength > 300 {
                    state.detail = state.detail
                    return .none
                }
                
                if detail.contains("  ") {
                    state.detail = state.detail
                    return .none
                }
                
                if detail.first == " " {
                    state.detail = ""
                    return .none
                }
                    
                state.detail = detail
                
                validateEditorState(&state)
                
            case let .textValidation(.categoryValidtaion(category)):
                if category == "카테고리를 선택해주세요" {
                    return .none
                }
                
                validateEditorState(&state)
                
            case let .bindingTitle(titleText):
                state.title = titleText
                
            case let .bindingLocation(locationText):
                state.location = locationText

            case let .bindingDetail(detail):
                state.detail = detail
                
            case let .bindingHashTag(hashTag):
                state.hashTag = hashTag
                
            case let .bindingPresent(isPresent):
                state.isPresent = isPresent
                
            case let .bindingPermission(permission):
                state.showPermissionAlert = permission
                
            default:
                break
            }
            
            return .none
        }
    }
    
    private func validateEditorState(_ state: inout State) {
        state.spotEditorIsValid = !state.title.isEmpty && !state.detail.isEmpty && !state.location.isEmpty && state.categoryText != "카테고리를 선택해주세요"
    }
}
