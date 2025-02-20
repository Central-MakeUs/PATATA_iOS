//
//  ReportFeature.swift
//  Patata
//
//  Created by 김진수 on 2/18/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ReportFeature {
    @ObservableState
    struct State: Equatable {
        var viewState: ViewState
        var id: Int
        var reportOption: [ReportOption] = ReportOption.allCases
        var selectedIndex: Int = 5
        var textFieldText: String = ""
        var textCount: Int = 0
        var buttonIsValid: Bool = false
    }
    
    enum ReportOption: String, CaseIterable {
        case inappropriate
        case harmful
        case privacy
        case other
        
        func description(for viewState: ViewState) -> String {
            switch (self, viewState) {
            case (.inappropriate, .user), (.inappropriate, .review):
                return "비매너 사용자에요"
            case (.inappropriate, .post):
                return "홍보성 스팸성"
                
            case (.harmful, .user), (.harmful, .review):
                return "게시글을 반복적으로 올려요"
            case (.harmful, .post):
                return "욕설 및 험오 표현"
                
            case (.privacy, .user), (.privacy, .review):
                return "적절하지 않은 게시글을 반복적으로 올려요"
            case (.privacy, .post):
                return "개인정보 노출 및 저작권 침해"
                
            case (.other, _):
                return "기타"
            }
        }
    }
    
    enum ViewState {
        case user
        case post
        case review
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case delegate(Delegate)
        
        case bindingTextFieldText(String)
        
        enum Delegate {
            case tappedConfirmButton
            case tappedBackButton
        }
    }
    
    enum ViewEvent {
        case tappedCheckButton(Int)
        case tappedBackButton
        case tappedConfirmButton
        case changeTextCount(Int)
        case textValidation(String)
    }
    
    enum NetworkType {
        case spot
        case user
        case review
    }
    
    @Dependency(\.reportRepository) var reportRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.tappedCheckButton(index)):
                state.selectedIndex = index
                
                if state.selectedIndex == 4 && !state.textFieldText.isEmpty {
                    state.buttonIsValid = true
                    
                } else if state.selectedIndex != 4 {
                    state.buttonIsValid = true
                }
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.tappedConfirmButton):
                return .send(.delegate(.tappedConfirmButton))
                
            case let .viewEvent(.changeTextCount(count)):
                state.textCount = count
                
            case let .viewEvent(.textValidation(text)):
                let totalLength = text.reduce(0) { count, char in
                    if char == "\n" {
                        return count + 1
                    }
                    return count + 1
                }
                
                if totalLength > 300 {
                    state.textFieldText = state.textFieldText
                    return .none
                }
                
                if text.contains("  ") {
                    state.textFieldText = state.textFieldText
                    return .none
                }
                
                if text.first == " " {
                    state.textFieldText = ""
                    return .none
                }
                
                if state.selectedIndex == 4 && !state.textFieldText.isEmpty {
                    state.buttonIsValid = false
                }
                    
                state.textFieldText = text
                
            case .networkType(.spot):
                let spotId = state.id
                let reason = state.reportOption[safe: state.selectedIndex]?.rawValue ?? ""
                let textField = state.textFieldText
                
                return .run { send in
                    do {
                        try await reportRepository.reportSpot(spotId: spotId, reason: reason, des: textField)
                        
                        await send(.delegate(.tappedConfirmButton))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.review):
                let reviewId = state.id
                let reason = state.reportOption[safe: state.selectedIndex]?.rawValue ?? ""
                let textField = state.textFieldText
                
                return .run { send in
                    do {
                        try await reportRepository.reportReview(reviewId: reviewId, reason: reason, des: textField)
                        
                        await send(.delegate(.tappedConfirmButton))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.user):
                let memberId = state.id
                let reason = state.reportOption[safe: state.selectedIndex]?.rawValue ?? ""
                let textField = state.textFieldText
                
                return .run { send in
                    do {
                        try await reportRepository.reportUser(memberId: memberId, reason: reason, des: textField)
                        
                        await send(.delegate(.tappedConfirmButton))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .bindingTextFieldText(text):
                state.textFieldText = text

            default:
                break
            }
            return .none
        }
    }
}
