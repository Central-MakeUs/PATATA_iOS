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
        var viewState: ViewState
        var dataState: DataState = .data
        var profileImage: String = "ProfileImage"
        var nickname: String = ""
        let profileData: MyPageEntity
        var isValid: Bool = true
        var textValueChange: Bool = false
        var cancleButtonHide: Bool = true
        var imageData: [Data] = []
    }
    
    enum ViewState {
        case first
        case edit
    }
    
    enum DataState {
        case progress
        case data
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case viewCycle(ViewCycle)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case validCheckText(String)
        case delegate(Delegate)
        
        // bindingAction
        case bindingNickname(String)
        case bindingImageData([Data])
        
        enum Delegate {
            case tappedBackButton(ViewState)
            case successChangeNickname
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum NetworkType {
        case changeNickname
        case changeProfileImage
    }
    
    enum ViewEvent {
        case tappedClearNickName
        case tappedBackButton
        case tappedConfirmButton
        case imageChange
    }
    
    enum DataTransType {
        case nicknameData(Bool)
        case errorHandle(String)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.myPageRepository) var myPageRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension ProfileEditFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.dataState = .data
                state.nickname = state.profileData.nickName
                
            case .viewEvent(.tappedClearNickName):
                state.nickname = ""
                state.textValueChange = false
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton(state.viewState)))
                
            case .viewEvent(.imageChange):
                if !state.nickname.isEmpty && state.nickname.count >= 2 {
                    state.textValueChange = true
                }
                
            case .viewEvent(.tappedConfirmButton):
                if state.nickname != UserDefaultsManager.nickname && state.nickname.count >= 2 {
                    return .run { send in
                        await send(.networkType(.changeNickname))
                    }
                } else if !state.imageData.isEmpty && state.nickname == UserDefaultsManager.nickname {
                    return .run { send in
                        await send(.networkType(.changeProfileImage))
                    }
                }
                
            case .networkType(.changeProfileImage):
                let imageData = state.imageData[0]
                state.dataState = .progress
                
                return .run { send in
                    do {
                        let result = try await myPageRepository.uploadImage(image: imageData)
                        
                        await send(.delegate(.successChangeNickname))
                    } catch {
                        print("error", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.changeNickname):
                return .run { [state = state] send in
                    do {
                        let result = try await myPageRepository.chageNickname(nickname: state.nickname)
                        
                        await send(.dataTransType(.nicknameData(result)))
                    } catch {
                        let errorMSG = errorManager.handleError(error) ?? ""
                        print("error", errorMSG)
                        await send(.dataTransType(.errorHandle(errorMSG)))
                    }
                }
                
            case let .dataTransType(.nicknameData(isValid)):
                state.isValid = true
                UserDefaultsManager.nickname = state.nickname
                
                if state.imageData.isEmpty {
                    return .send(.delegate(.successChangeNickname))
                } else {
                    return .run { send in
                        await send(.networkType(.changeProfileImage))
                    }
                }
                
            case let .dataTransType(.errorHandle(isValid)):
                if isValid == "이미 사용중인 닉네임입니다." {
                    state.isValid = false
                }
                
                state.dataState = .data
                
            case let .validCheckText(nickname):
                let limitedText = String(nickname.prefix(10))
                
                if limitedText.first == " " {
                    state.nickname = ""
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
                
                var allowedCharacters = CharacterSet()
                allowedCharacters.formUnion(.letters)
                allowedCharacters.formUnion(.whitespaces)
                allowedCharacters.insert(charactersIn: "가-힣")
                
                let filteredText = limitedText.unicodeScalars.filter {
                    allowedCharacters.contains($0)
                }.reduce(into: "") { result, scalar in
                    result.append(String(scalar))
                }
                
                if filteredText.isEmpty {
                    state.textValueChange = false
                } else if filteredText == state.profileData.nickName {
                    state.textValueChange = false
                } else if filteredText.count >= 2 {
                    state.textValueChange = true
                } else {
                    state.textValueChange = false
                }
                
                state.nickname = filteredText
                state.isValid = true
                
            case let .bindingNickname(nickname):
                state.nickname = nickname
                state.cancleButtonHide = false
                
            case let .bindingImageData(imageData):
                state.imageData = imageData
              
            default:
                break
            }
            return .none
        }
    }
}
