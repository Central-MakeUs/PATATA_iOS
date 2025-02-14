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
            case tappedCategoryButton(CategoryCase)
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
        case tappedArchiveButton(Int, card: Bool)
        case tappedCategoryButton(CategoryCase)
    }
    
    enum NetworkType {
        case fetchCategorySpot(Int)
        case fetchTodaySpot
        case patchArchiveState(Int, card: Bool)
    }
    
    enum DataTransType {
        case categorySpot([SpotEntity])
        case todaySpot([TodaySpotEntity])
        case archiveState(ArchiveEntity, Int, card: Bool)
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
        Reduce {
            state,
            action in
            switch action {
            case .viewCycle(.onAppear):
                let categoryIndex = state.selectedIndex
                
                return .run { send in
                    await send(.networkType(.fetchCategorySpot(categoryIndex)))
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
                
            case let .viewEvent(.tappedArchiveButton(index, isCard)):
                return .run { send in
                    await send(.networkType(.patchArchiveState(index, card: isCard)))
                }
                
            case let .viewEvent(.tappedCategoryButton(category)):
                return .send(.delegate(.tappedCategoryButton(category)))
                
            case let .networkType(.fetchCategorySpot(index)):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchSpotCategory(category: CategoryCase(rawValue: index) ?? .all)
                        
                        await send(.dataTransType(.categorySpot(data.spots)))
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
                
            case let .networkType(.patchArchiveState(index, isCard)):
                if isCard {
                    return .run { [state = state] send in
                        do {
                            let data = try await archiveRepository.toggleArchive(spotId: state.todaySpotItems[index].spotId)
                            
                            await send(.dataTransType(.archiveState(data, index, card: isCard)))
                        } catch {
                            print(errorManager.handleError(error) ?? "")
                        }
                    }
                } else {
                    return .run { [state = state] send in
                        do {
                            let data = try await archiveRepository.toggleArchive(spotId: String(state.spotItems[index].spotId))
                            
                            await send(.dataTransType(.archiveState(data, index, card: isCard)))
                        } catch {
                            print(errorManager.handleError(error) ?? "")
                        }
                    }
                }
                
            case let .dataTransType(.todaySpot(data)):
                state.todaySpotItems = data
                
            case let .dataTransType(.categorySpot(data)):
                state.spotItems = data
                
            case let .dataTransType(.archiveState(data, index, isCard)):
                if isCard {
                    state.todaySpotItems[index] = TodaySpotEntity(
                        spotId: state.todaySpotItems[index].spotId,
                        spotAddress: state.todaySpotItems[index].spotAddress,
                        spotName: state.todaySpotItems[index].spotName,
                        category: state.todaySpotItems[index].category,
                        imageUrl: state.todaySpotItems[index].imageUrl,
                        isScraped: data.isArchive,
                        tags: state.todaySpotItems[index].tags
                    )
                    
                    if let index = state.spotItems.firstIndex(where: { String($0.spotId) == state.todaySpotItems[index].spotId }) {
                        state.spotItems[index] = SpotEntity(
                            spotId: state.spotItems[index].spotId,
                            spotAddress: state.spotItems[index].spotAddress,
                            spotName: state.spotItems[index].spotName,
                            category: state.spotItems[index].category,
                            imageUrl: state.spotItems[index].imageUrl,
                            reviews: state.spotItems[index].reviews,
                            spotScraps: state.spotItems[index].spotScraps,
                            isScraped: data.isArchive,
                            tags: state.spotItems[index].tags
                        )
                    }
                    
                } else {
                    state.spotItems[index] = SpotEntity(
                        spotId: state.spotItems[index].spotId,
                        spotAddress: state.spotItems[index].spotAddress,
                        spotName: state.spotItems[index].spotName,
                        category: state.spotItems[index].category,
                        imageUrl: state.spotItems[index].imageUrl,
                        reviews: state.spotItems[index].reviews,
                        spotScraps: state.spotItems[index].spotScraps,
                        isScraped: data.isArchive,
                        tags: state.spotItems[index].tags
                    )
                    
                    if let index = state.todaySpotItems.firstIndex(where: { $0.spotId == String(state.spotItems[index].spotId) }) {
                        
                        state.todaySpotItems[index] = TodaySpotEntity(
                            spotId: state.todaySpotItems[index].spotId,
                            spotAddress: state.todaySpotItems[index].spotAddress,
                            spotName: state.todaySpotItems[index].spotName,
                            category: state.todaySpotItems[index].category,
                            imageUrl: state.todaySpotItems[index].imageUrl,
                            isScraped: data.isArchive,
                            tags: state.todaySpotItems[index].tags
                        )
                    }
                }
                
            default:
                break
            }
            
            return .none
        }
    }
}
