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
            case tappedSpot // 보낼때 데이터도 같이
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
        case tappedSpot // 보낼때 데이터도 같이
        case tappedMoreButton
    }
    
    enum NetworkType {
        case fetchCategorySpot
    }
    
    enum DataTransType {
        case categorySpot([SpotEntity])
    }
    
    @Dependency(\.spotRepository) var spotRepository
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
                    await send(.networkType(.fetchCategorySpot))
                }
                
            case let .viewEvent(.selectCategory(index)):
                state.selectedIndex = index
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.tappedAddButton):
                return .send(.delegate(.tappedAddButton))
                
            case .viewEvent(.tappedSpot):
                return .send(.delegate(.tappedSpot))
                
            case .viewEvent(.tappedMoreButton):
                return .send(.delegate(.tappedMoreButton))
                
            case .networkType(.fetchCategorySpot):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchSpotCategory(category: .snapSpot)
                        
                        await send(.dataTransType(.categorySpot(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.categorySpot(data)):
                state.spotItems = data
                
            default:
                break
            }
            
            return .none
        }
    }
}
