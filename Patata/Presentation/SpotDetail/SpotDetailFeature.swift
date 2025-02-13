//
//  SpotDetailFeature.swift
//  Patata
//
//  Created by 김진수 on 1/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SpotDetailFeature {
    @ObservableState
    struct State: Equatable {
        var isHomeCoordinator: Bool
        var spotId: String
        var spotDetailData: SpotDetailEntity = SpotDetailEntity()
        
        // bindingState
        var currentIndex: Int = 0
        var saveIsTapped: Bool = false
        var commentText: String = ""
        var bottomSheetIsPresent: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        // bindingAction
        case bindingCurrentIndex(Int)
        case bindingSaveIsTapped(Bool)
        case bindingCommentText(String)
        case bindingBottomSheetIsPresent(Bool)
        
        enum Delegate {
            case tappedNavBackButton
            case tappedDismissIcon
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case bottomSheetOpen
        case bottomSheetClose
        case tappedNavBackButton
        case tappedDismissIcon
    }
    
    enum NetworkType {
        case fetchSpotDetail(String)
    }
    
    enum DataTransType {
        case spotDetail(SpotDetailEntity)
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotDetailFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { [state = state] send in
                    await send(.networkType(.fetchSpotDetail(state.spotId)))
                }
                
            case .viewEvent(.tappedNavBackButton):
                return .send(.delegate(.tappedNavBackButton))
                
            case .viewEvent(.bottomSheetOpen):
                state.bottomSheetIsPresent = true
                
            case .viewEvent(.bottomSheetClose):
                state.bottomSheetIsPresent = false
                
            case .viewEvent(.tappedDismissIcon):
                return .send(.delegate(.tappedDismissIcon))
                
            case let .networkType(.fetchSpotDetail(spotId)):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchSpot(spotId: spotId)
                        
                        await send(.dataTransType(.spotDetail(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.spotDetail(data)):
                state.spotDetailData = data
                
            case let .bindingCurrentIndex(index):
                print("index", index)
                state.currentIndex = index
                
            case let .bindingSaveIsTapped(isTapped):
                state.saveIsTapped = isTapped
                
            case let .bindingCommentText(comment):
                state.commentText = comment
                
            case let .bindingBottomSheetIsPresent(isPresent):
                state.bottomSheetIsPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}
