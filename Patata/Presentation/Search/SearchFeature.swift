//
//  SearchFeature.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchFeature {
    private let dataSourceActor = DataSourceActor()
    
    @ObservableState
    struct State: Equatable {
        var searchSpotItems: [SearchSpotEntity] = []
        var itemTotalCount: Int = 0
        var pageTotalCount: Int = 0
        var beforeViewState: BeforeViewState
        var searchText: String = ""
        var searchResult: Bool = true
        var listLoadTrigger: Bool = true
        var viewState: ViewState = .search
        var userLocation: Coordinate = Coordinate(latitude: 126.9784147, longitude: 37.5666885)
    }
    
    enum ViewState {
        case loading
        case search
        case searchResult
    }
    
    enum BeforeViewState {
        case home
        case map
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case switchViewState
        case delegate(Delegate)
        
        // bindingAction
        case bindingSearchText(String)
        
        enum Delegate {
            case tappedBackButton
            case successSearch
            case tappedSpotDetail(String)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedBackButton
        case searchOnSubmit
        case searchStart
        case tappedSpotDetail(String)
        case tappedArchiveButton(Int)
        case nextPage
    }
    
    enum NetworkType {
        case searchSpot(page: Int, filter: FilterCase, scroll: Bool)
        case patchArchiveState(Int)
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case searchSpot(SearchSpotCountEntity, Bool)
        case archiveState(ArchiveEntity, Int)
        case error
    }
    
    enum CancelId: Hashable {
        case scrollID
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SearchFeature {
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
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.searchOnSubmit):
                if state.beforeViewState == .home {
                    state.viewState = .loading
                }
                
                if state.beforeViewState == .home {
                    return .run { send in
                        await send(.networkType(.searchSpot(page: 0, filter: .recommend, scroll: false)))
                    }
                } else {
                    return .send(.delegate(.successSearch))
                }
                
            case .viewEvent(.searchStart):
                state.searchText = ""
                state.viewState = .search
                
            case let .viewEvent(.tappedSpotDetail(spotId)):
                return .send(.delegate(.tappedSpotDetail(spotId)))
                
            case let .viewEvent(.tappedArchiveButton(index)):
                return .run { send in
                    await send(.networkType(.patchArchiveState(index)))
                }
                
            case .viewEvent(.nextPage):
                state.listLoadTrigger = false
                
                return .run { [state = state] send in
                    await send(.networkType(.searchSpot(page: state.pageTotalCount + 1, filter: .recommend, scroll: true)))
                }
                
            case let .networkType(.searchSpot(page, filer, scroll)):
                return .run { [state = state] send in
                    do {
                        let data = try await spotRepository.fetchSearch(searchText: state.searchText, page: page, sortBy: filer)
                        
                        await send(.dataTransType(.searchSpot(data, scroll)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                        await send(.dataTransType(.error))
                    }
                }
                
            case let .networkType(.patchArchiveState(index)):
                return .run { [state = state] send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: state.searchSpotItems[index].spotId)
                        
                        await send(.dataTransType(.archiveState(data, index)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                
            case let .dataTransType(.searchSpot(data, scroll)):
                if data.totalCount != 0 {
                    if scroll {
                        state.searchResult = true
                        state.itemTotalCount = data.totalCount
                        state.pageTotalCount = data.totalPages
                        state.searchSpotItems.append(contentsOf: data.spots)
                        state.listLoadTrigger = true
                        
                    } else {
                        state.searchResult = true
                        state.itemTotalCount = data.totalCount
                        state.pageTotalCount = data.totalPages
                        state.searchSpotItems = data.spots
                        state.listLoadTrigger = true
                    }
                    if state.beforeViewState == .home && state.viewState == .loading {
                        return .send(.switchViewState)
                    }
                        
                } else {
                    state.viewState = .search
                    state.searchResult = false
                }
                
            case let .dataTransType(.archiveState(data, index)):
                state.searchSpotItems[index] = SearchSpotEntity(
                    spotId: state.searchSpotItems[index].spotId,
                    spotName: state.searchSpotItems[index].spotName,
                    imageUrl: state.searchSpotItems[index].imageUrl,
                    spotScraps: state.searchSpotItems[index].spotScraps,
                    isScraped: data.isArchive,
                    reviews: state.searchSpotItems[index].reviews,
                    distance: state.searchSpotItems[index].distance
                )
                
            case .dataTransType(.error):
                state.viewState = .search
                
            case .switchViewState:
                state.viewState = .searchResult
                
            case let .bindingSearchText(text):
                state.searchText = text
                
            default:
                break
            }
            return .none
        }
    }
}
