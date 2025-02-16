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
        var tappedSpotList: [Int] = []
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {

        }
        
        // bindingAction

    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedSpot(Int)
    }
    
    enum NetworkType {
        case fetchArchiveList
    }
    
    enum DataTransType {
        case fetchArchiveList([ArchiveListEntity])
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
                if state.tappedSpotList.contains(spotId) {
                    state.tappedSpotList.removeAll { $0 == spotId }
                } else {
                    state.tappedSpotList.append(spotId)
                }
                
            case .networkType(.fetchArchiveList):
                return .run { send in
                    do {
                        let data = try await archiveRepository.fetchArchiveList()
                        
                        await send(.dataTransType(.fetchArchiveList(data)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.fetchArchiveList(data)):
                state.archiveList = data
                
            default :
                break
            }
            return .none
        }
    }
}
