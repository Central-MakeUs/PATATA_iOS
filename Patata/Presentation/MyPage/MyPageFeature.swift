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
        var profileImage: String = "MyPageActive"
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
            case tappedSpot
            case tappedProfileEdit
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedSpot
        case tappedProfileEdit
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
                
            case .viewEvent(.tappedSpot):
                return .send(.viewEvent(.tappedSpot))
                
            case .viewEvent(.tappedProfileEdit):
                return .send(.viewEvent(.tappedProfileEdit))
                
            case .networkType(.fetchMySpot):
                return .run { send in
                    do {
                        let data = try await myPageRepository.fetchMySpots()
                        
                        await send(.dataTransType(.fetchMySpot(data)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
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
