//
//  MyPageFeature.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyPageFeature {
    @ObservableState
    struct State: Equatable {
        var imageCount: Int = 0
        var profileImage: String = "ProfileImage"
        var nickname: String = UserDefaultsManager.nickname
        var email: String = "adsafas@gmail.com"
        var spotCount: Int = 0
        var mySpots: [ArchiveListEntity] = []
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSpot(Int)
            case tappedProfileEdit
            case tappedSetting
            case changeNickName
            case tappedAddSpotButton
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedSpot(Int)
        case tappedProfileEdit
        case tappedSetting
        case tappedAddSpotButton
    }
    
    enum NetworkType {
        case fetchMySpot
    }
    
    enum DataTransType {
        case fetchMySpot(MySpotsEntity)
    }
    
    @Dependency(\.myPageRepository) var myPageRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.networkType(.fetchMySpot))
                }
                
            case let .viewEvent(.tappedSpot(spotId)):
                return .send(.delegate(.tappedSpot(spotId)))
                
            case .viewEvent(.tappedProfileEdit):
                return .send(.delegate(.tappedProfileEdit))
                
            case .viewEvent(.tappedSetting):
                return .send(.delegate(.tappedSetting))
                
            case .viewEvent(.tappedAddSpotButton):
                return .send(.delegate(.tappedAddSpotButton))
                
            case .networkType(.fetchMySpot):
                return .run { send in
                    do {
                        let data = try await myPageRepository.fetchMySpots()
                        
                        await send(.dataTransType(.fetchMySpot(data)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .delegate(.changeNickName):
                state.nickname = UserDefaultsManager.nickname
                
            case let .dataTransType(.fetchMySpot(data)):
                state.spotCount = data.spotCount
                state.mySpots = data.mySpots
                
            default:
                break
            }
            return .none
        }
    }
}
