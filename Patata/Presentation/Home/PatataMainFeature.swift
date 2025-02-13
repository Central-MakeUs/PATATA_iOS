//
//  PatataMainFeature.swift
//  Patata
//
//  Created by 김진수 on 1/16/25.
//

import ComposableArchitecture

@Reducer
struct PatataMainFeature {
    
    @ObservableState
    struct State: Equatable {
        var todaySpotItems: [TodaySpotEntity] = []
        var spotItems: [SpotEntity] = []
        var categorySelect: Bool = false
        var selectedIndex: Int = 0
        var currentIndex: Int = 0
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSearch
            case tappedAddButton
            case tappedSpot(String)
            case tappedMoreButton
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case selectCategory(Int)
        case tappedSearch
        case tappedAddButton
        case tappedSpot(String)
        case tappedMoreButton
        case tappedArchiveButton(Int)
    }
    
    enum NetworkType {
        case fetchCategorySpot(Int)
        case fetchTodaySpot
        case patchArchiveState(Int)
    }
    
    enum DataTransType {
        case categorySpot([SpotEntity])
        case todaySpot([TodaySpotEntity])
        case archiveState(ArchiveEntity, Int)
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension PatataMainFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.networkType(.fetchCategorySpot(0)))
                    await send(.networkType(.fetchTodaySpot))
                }
                
            case let .viewEvent(.selectCategory(index)):
                state.selectedIndex = index
                
                return .run { send in
                    await send(.networkType(.fetchCategorySpot(index)))
                }
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.tappedAddButton):
                return .send(.delegate(.tappedAddButton))
                
            case let .viewEvent(.tappedSpot(spotId)):
                return .send(.delegate(.tappedSpot(spotId)))
                
            case .viewEvent(.tappedMoreButton):
                return .send(.delegate(.tappedMoreButton))
                
            case let .viewEvent(.tappedArchiveButton(index)):
                return .run { send in
                    await send(.networkType(.patchArchiveState(index)))
                }
                
            case let .networkType(.fetchCategorySpot(index)):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchSpotCategory(category: CategoryCase(rawValue: index) ?? .all)
                        
                        await send(.dataTransType(.categorySpot(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.fetchTodaySpot):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchTodaySpot()
                        
                        await send(.dataTransType(.todaySpot(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .networkType(.patchArchiveState(index)):
                return .run { [state = state] send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: state.todaySpotItems[index].spotId)
                        print("success patchArchiveState", data)
                        await send(.dataTransType(.archiveState(data, index)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.todaySpot(data)):
                state.todaySpotItems = data
                
            case let .dataTransType(.categorySpot(data)):
                state.spotItems = data
                
            case let .dataTransType(.archiveState(data, index)):
                state.todaySpotItems[index] = TodaySpotEntity(
                    spotId: state.todaySpotItems[index].spotId,
                    spotAddress: state.todaySpotItems[index].spotAddress,
                    spotName: state.todaySpotItems[index].spotName,
                    category: state.todaySpotItems[index].category,
                    imageUrl: state.todaySpotItems[index].imageUrl,
                    isScraped: data.isArchive,
                    tags: state.todaySpotItems[index].tags
                )
                
            default:
                break
            }
            
            return .none
        }
    }
}
