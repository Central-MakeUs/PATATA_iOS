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
        var spotId: Int
        var spotDetailData: SpotDetailEntity = SpotDetailEntity()
        var reviewData: [SpotDetailReviewEntity] = []
        
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
            case tappedNavBackButton(Bool)
            case tappedDismissIcon
            case delete
            case editSpotDetail(SpotDetailEntity)
            case report(String)
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
        case tappedOnSubmit
        case tappedDeleteReview(reviewId: Int, index: Int)
    }
    
    enum NetworkType {
        case fetchSpotDetail(Int)
        case patchArchiveState
        case deleteSpot
        case createReview(String)
        case deleteReview(reviewId: Int, index: Int)
    }
    
    enum DataTransType {
        case spotDetail(SpotDetailEntity)
        case archiveState(ArchiveEntity)
        case reviewData(ReviewEntity)
        case deleteReviewData(index: Int)
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.reviewRepository) var reviewRepository
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
                return .send(.delegate(.tappedNavBackButton(state.spotDetailData.isScraped)))
                
            case .viewEvent(.bottomSheetOpen):
                state.bottomSheetIsPresent = true
                
            case let .viewEvent(.bottomSheetClose(text)):
                state.bottomSheetIsPresent = false
                
                if text == "게시글 신고하기" {
                    return .send(.delegate(.report("Post")))
                } else if text == "사용자 신고하기" {
                    return .send(.delegate(.report("User")))
                } else if text == "게시글 수정하기" {
                    print("editSPot", state.spotDetailData.spotCoord)
                    return .send(.delegate(.editSpotDetail(state.spotDetailData)))
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
                return .run { send in
                    await send(.networkType(.deleteSpot))
                }
                
            case .viewEvent(.tappedOnSubmit):
                let comment = state.commentText
                
                return .run { send in
                    await send(.networkType(.createReview(comment)))
                }
                
            case let .viewEvent(.tappedDeleteReview(reviewId, index)):
                return .run { send in
                    await send(.networkType(.deleteReview(reviewId: reviewId, index: index)))
                }
                
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
                let spotId = [state.spotDetailData.spotId]
                
                return .run { send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: spotId)
                        
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
                
            case let .networkType(.createReview(comment)):
                return .run { [state = state] send in
                    do {
                        let data = try await reviewRepository.createReview(spotId: state.spotDetailData.spotId, text: comment)
                        
                        await send(.dataTransType(.reviewData(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .networkType(.deleteReview(reviewId, index)):
                return .run { send in
                    do {
                        try await reviewRepository.deleteReview(reviewId: reviewId)
                        
                        await send(.dataTransType(.deleteReviewData(index: index)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.spotDetail(data)):
                print("fetch", data.spotCoord)
                state.spotDetailData = data
                state.reviewData = data.reviews
                
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
                
            case let .dataTransType(.reviewData(review)):
                state.commentText = ""
                let reviewData = SpotDetailReviewEntity(reviewId: review.reviewId, memberName: UserDefaultsManager.nickname, reviewText: review.reviewText)
                state.reviewData.append(reviewData)
                
            case let .dataTransType(.deleteReviewData(index: index)):
                state.reviewData.remove(at: index)
                
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
