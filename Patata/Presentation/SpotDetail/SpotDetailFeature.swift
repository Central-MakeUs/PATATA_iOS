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
        var alertIsPresent: Bool = false
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
        case bindingAlertIsPresent(Bool)
        
        enum Delegate {
            case tappedNavBackButton
            case tappedDismissIcon
            case delete
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case bottomSheetOpen
        case bottomSheetClose(String)
        case tappedNavBackButton
        case tappedDismissIcon
        case tappedArchiveButton
        case tappedDeleteButton
    }
    
    enum NetworkType {
        case fetchSpotDetail(String)
        case patchArchiveState
        case deleteSpot
    }
    
    enum DataTransType {
        case spotDetail(SpotDetailEntity)
        case archiveState(ArchiveEntity)
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotDetailFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { [state = state] send in
                    await send(.networkType(.fetchSpotDetail(state.spotId)))
                }
                
            case .viewEvent(.tappedNavBackButton):
                return .send(.delegate(.tappedNavBackButton))
                
            case .viewEvent(.bottomSheetOpen):
                state.bottomSheetIsPresent = true
                
            case let .viewEvent(.bottomSheetClose(text)):
                state.bottomSheetIsPresent = false
                
                if text == "게시글 신고하기" {
                    
                } else if text == "사용자 신고하기" {
                    
                } else if text == "게시글 수정하기" {
                    
                } else {
                    state.alertIsPresent = true
                }
                
            case .viewEvent(.tappedDismissIcon):
                return .send(.delegate(.tappedDismissIcon))
                
            case .viewEvent(.tappedArchiveButton):
                return .run { send in
                    await send(.networkType(.patchArchiveState))
                }
                
            case .viewEvent(.tappedDeleteButton):
                // 네트워크하고 끝나면 딜리게이트로 보내자
                return .send(.delegate(.delete))
                
            case let .networkType(.fetchSpotDetail(spotId)):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchSpot(spotId: spotId)
                        
                        await send(.dataTransType(.spotDetail(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.patchArchiveState):
                return .run { [state = state] send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: String(state.spotDetailData.spotId))
                        
                        await send(.dataTransType(.archiveState(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.deleteSpot):
                return .run { [state = state] send in
                    do {
                        try await spotRepository.deleteSpot(spotId: state.spotDetailData.spotId)
                        
                        await send(.delegate(.delete))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.spotDetail(data)):
                state.spotDetailData = data
                
            case let .dataTransType(.archiveState(data)):
                state.spotDetailData = SpotDetailEntity(
                    spotId: state.spotDetailData.spotId,
                    isAuthor: state.spotDetailData.isAuthor,
                    spotAddress: state.spotDetailData.spotAddress,
                    spotAddressDetail: state.spotDetailData.spotAddressDetail,
                    spotName: state.spotDetailData.spotName,
                    spotDescription: state.spotDetailData.spotDescription,
                    categoryId: state.spotDetailData.categoryId,
                    memberName: state.spotDetailData.memberName,
                    images: state.spotDetailData.images,
                    reviewCount: state.spotDetailData.reviewCount,
                    isScraped: data.isArchive,
                    tags: state.spotDetailData.tags,
                    reviews: state.spotDetailData.reviews
                )
                
            case let .bindingCurrentIndex(index):
                state.currentIndex = index
                
            case let .bindingSaveIsTapped(isTapped):
                state.saveIsTapped = isTapped
                
            case let .bindingCommentText(comment):
                state.commentText = comment
                
            case let .bindingBottomSheetIsPresent(isPresent):
                state.bottomSheetIsPresent = isPresent
                
            case let .bindingAlertIsPresent(isPresent):
                state.alertIsPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}
