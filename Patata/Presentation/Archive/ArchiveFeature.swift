//
//  ArchiveFeature.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ArchiveFeature {

    @ObservableState
    struct State: Equatable {
        var archiveList: [ArchiveListEntity] = []
        var deleteText: String = ""
        var selectedSpotList: [Int] = []
        var chooseIsValid: Bool = false
        var isPresent: Bool = false
        var popupIsPresent: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSpot(Int)
            case tappedConfirmButton
        }
        
        // bindingAction
        case bindingIsPresent(Bool)
        case bindingPopupIsPresent(Bool)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedSpot(Int)
        case tappedChoseButton
        case tappedDeleteButton
        case dismissAlert
        case dismissPopup
        case tappedConfirmButton
    }
    
    enum NetworkType {
        case fetchArchiveList
        case patchArchiveState([Int])
    }
    
    enum DataTransType {
        case fetchArchiveList([ArchiveListEntity])
        case successDelete
    }
    
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.errorManager) var errorManager

    var body: some ReducerOf<Self> {
        core()
    }
}

extension ArchiveFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.networkType(.fetchArchiveList))
                }
                
            case let .viewEvent(.tappedSpot(spotId)):
                if state.chooseIsValid {
                    if state.selectedSpotList.contains(spotId) {
                        state.selectedSpotList.removeAll { $0 == spotId }
                    } else {
                        state.selectedSpotList.append(spotId)
                    }
                } else {
                    return .send(.delegate(.tappedSpot(spotId)))
                }
                
            case .viewEvent(.tappedChoseButton):
                if state.chooseIsValid && !state.selectedSpotList.isEmpty {
                    state.isPresent = true
                } else if state.chooseIsValid {
                    state.chooseIsValid = false
                } else {
                    state.chooseIsValid = true
                }
                
            case .viewEvent(.tappedDeleteButton):
                let deleteList = state.selectedSpotList
                
                return .run { send in
                    await send(.networkType(.patchArchiveState(deleteList)))
                }
                
            case .viewEvent(.tappedConfirmButton):
                return .send(.delegate(.tappedConfirmButton))
                
            case .viewEvent(.dismissAlert):
                state.selectedSpotList = []
                state.chooseIsValid = false
                state.isPresent = false
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case .networkType(.fetchArchiveList):
                return .run { send in
                    do {
                        let data = try await archiveRepository.fetchArchiveList()
                        
                        await send(.dataTransType(.fetchArchiveList(data)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .networkType(.patchArchiveState(spots)):
                return .run { send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: spots)
                        
                        await send(.dataTransType(.successDelete))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.fetchArchiveList(data)):
                state.archiveList = data
                
            case .dataTransType(.successDelete):
                var archiveList = state.archiveList
                
                archiveList.removeAll { item in
                    state.selectedSpotList.contains(item.spotId)
                }
                state.chooseIsValid = false
                state.deleteText = "\(state.selectedSpotList.count)개의 항목이 삭제되었습니다!"
                state.archiveList = archiveList
                
            case let .bindingIsPresent(isPresent):
                state.isPresent = isPresent
                
            case let .bindingPopupIsPresent(popupIsPresent):
                state.popupIsPresent = popupIsPresent
                
            default :
                break
            }
            return .none
        }
    }
}
