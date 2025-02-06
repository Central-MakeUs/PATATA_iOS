//
//  ProfileEditFeature.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation
import ComposableArchitecture

// 처음 프로필 수정뷰에 있을시에 프로필이미지는 어떻게 처리해야되나
@Reducer
struct ProfileEditFeature {
    @ObservableState
    struct State: Equatable {
        var profileImage: String = "MyPageActive"
        var nickname: String = ""
        var isValid: Bool = false
        var nickNameIsValid: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case validCheckText(String)
        case delegate(Delegate)
        
        // bindingAction
        case bindingNickname(String)
        
        enum Delegate {
            case tappedBackButton
        }
    }
    
    enum ViewEvent {
        case tappedClearNickName
        case tappedBackButton
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension ProfileEditFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedClearNickName):
                state.nickname = ""
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case let .validCheckText(nickname):
                
                if nickname.count >= 2 {
                    state.isValid = true
                }
                
                let limitedText = String(nickname.prefix(10))
                
                if limitedText.first == " " {
                    state.nickname = ""
                    state.isValid = false
                    return .none
                }
                
                // 연속된 공백 처리
                if limitedText.contains("  ") {
                    state.nickname = limitedText.replacingOccurrences(of: "  ", with: " ")
                    return .none
                }
                
                // 마지막 글자가 공백인 경우
                if let lastChar = state.nickname.last,
                   lastChar == " ",
                   limitedText.last == " " {
                    state.nickname = state.nickname
                    return .none
                }
                
                // 허용된 문자만 필터링
                var allowedCharacters = CharacterSet()
                allowedCharacters.formUnion(.alphanumerics)
                allowedCharacters.formUnion(.whitespaces)
                allowedCharacters.insert(charactersIn: "가-힣")
                
                let filteredText = limitedText.unicodeScalars.filter {
                    allowedCharacters.contains($0)
                }.reduce(into: "") { result, scalar in
                    result.append(String(scalar))
                }
                
                state.nickname = filteredText
                
            case let .bindingNickname(nickname):
                state.nickname = nickname
              
            default:
                break
            }
            return .none
        }
    }
}
