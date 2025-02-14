//
//  SpotCategoryFeature.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SpotCategoryFeature {
    private let dataSourceActor = DataSourceActor()
    
    @ObservableState
    struct State: Equatable {
        let category: [CategoryCase] = CategoryCase.allCases
        var userLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var currentPage: Int = 0
        var totalPages: Int = 0
        var totalCount: Int = 0
        var filter: FilterCase = .distance
        var selectedIndex: Int
        var listLoadTrigger: Bool = true
        var isPresent: Bool = false
        var filterText: String = "거리순"
        var spotItems: [SpotEntity] = []
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        
        case delegate(Delegate)
        
        // bindingAction
        case bindingIsPresent(Bool)
        
        enum Delegate {
            case tappedNavBackButton
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case fetchRealm
        case selectedMenu(Int)
        case openBottomSheet
        case tappedBottomSheetItem(String)
        case tappedNavBackButton
        case nextPage
    }
    
    enum NetworkType {
        case fetchCategoryItem(page: Int, filter: FilterCase, scroll: Bool, categoryId: Int, userLocation: Coordinate)
    }
    
    enum DataTransType {
        case fetchRealm
        case fetchCategoryItem(CategorySpotPageEntity, scroll: Bool)
        case userLocation(Coordinate)
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotCategoryFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .viewCycle(.onAppear):
                state.listLoadTrigger = false
                
                return .run { send in
                    await send(.dataTransType(.fetchRealm))
                    
                    for await location in locationManager.getLocationUpdates() {
                        await send(.dataTransType(.userLocation(location)))
                    }
                }
                
            case let .viewEvent(.selectedMenu(index)):
                state.selectedIndex = index
                state.listLoadTrigger = false
                state.currentPage = 0
                state.totalPages = 0
                
                let currentPage = state.currentPage
                let filter = state.filter
                let userLocation = state.userLocation
                
                return .run { send in
                    await send(
                        .networkType(
                            .fetchCategoryItem(
                                page: currentPage,
                                filter: filter,
                                scroll: false,
                                categoryId: index,
                                userLocation: userLocation
                            )
                        )
                    )
                }
                
            case .viewEvent(.openBottomSheet):
                state.isPresent = true
                
            case let .viewEvent(.tappedBottomSheetItem(filter)):
                state.filterText = filter
                state.filter = FilterCase.getFilter(text: filter)
                state.isPresent = false
                
                state.currentPage = 0
                state.totalPages = 0
                
                let currentPage = state.currentPage
                let filter = state.filter
                let userLocation = state.userLocation
                
                return .run { [state = state] send in
                    await send(
                        .networkType(
                            .fetchCategoryItem(
                                page: currentPage,
                                filter: filter,
                                scroll: false,
                                categoryId: state.selectedIndex,
                                userLocation: userLocation
                            )
                        )
                    )
                }
                
            case .viewEvent(.nextPage):
                state.listLoadTrigger = false
                let userLocation = state.userLocation
                
                return .run { [state = state] send in
                    await send(
                        .networkType(
                            .fetchCategoryItem(
                                page: state.currentPage + 1,
                                filter: state.filter,
                                scroll: true,
                                categoryId: state.selectedIndex,
                                userLocation: userLocation
                            )
                        )
                    )
                }
                
            case .viewEvent(.tappedNavBackButton):
                return .send(.delegate(.tappedNavBackButton))
                
            case let .networkType(.fetchCategoryItem(page, filter, scroll, categoryId, userLocation)):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchSpotCategory(
                            category: CategoryCase(rawValue: categoryId) ?? .all,
                            page: page,
                            latitude: userLocation.latitude,
                            longitude: userLocation.longitude ,
                            sortBy: filter.rawValue
                        )
                        
                        await send(.dataTransType(.fetchCategoryItem(data, scroll: scroll)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.fetchCategoryItem(data, scroll)):
                if scroll {
                    state.totalCount = data.totalCount
                    state.totalPages = data.totalPages
                    state.currentPage = data.currentPage
                    state.spotItems.append(contentsOf: data.spots)
                    state.listLoadTrigger = true
                    
                } else {
                    state.totalCount = data.totalCount
                    state.totalPages = data.totalPages
                    state.currentPage = data.currentPage
                    state.spotItems = data.spots
                    state.listLoadTrigger = true
                }
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                
                return .run { [state = state] send in
                    await send(
                        .networkType(
                            .fetchCategoryItem(
                                page: state.currentPage,
                                filter: state.filter,
                                scroll: false,
                                categoryId: state.selectedIndex,
                                userLocation: coord
                            )
                        )
                    )
                }
                
            case let .bindingIsPresent(isPresent):
                state.isPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}
