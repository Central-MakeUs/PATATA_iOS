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
        var currentPage: Int = 0
        var filter: FilterCase = .distance
        var beforeViewState: BeforeViewState
        var searchText: String = ""
        var searchResult: Bool = true
        var listLoadTrigger: Bool = true
        var viewState: ViewState = .search
        var userLocation: Coordinate = Coordinate(latitude: 37.5666885, longitude: 126.9784147)
        var scrollToTop: Bool = false
        var filterIsvalid: Bool = false
        var filterText: String = "거리순"
        var selectSpotIndex: Int = 0
    }
    
    enum ViewState {
        case search
        case searchResult
    }
    
    enum BeforeViewState {
        case home
        case map
        case searchMap
        case mySpotList
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        // bindingAction
        case bindingSearchText(String)
        case bindingFilterIsValid(Bool)
        
        enum Delegate {
            case tappedBackButton(BeforeViewState)
            case successSearch(String, BeforeViewState)
            case tappedSpotDetail(Int)
            case deletePop
            case detailBack(Bool)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedBackButton
        case searchOnSubmit
        case searchStart
        case tappedSpotDetail(Int, index: Int)
        case tappedArchiveButton(Int)
        case nextPage
        case dismissFilter(String)
        case openFilter
        case reset
    }
    
    enum NetworkType {
        case searchSpot(page: Int, filter: FilterCase, scroll: Bool, userLocation: Coordinate)
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
                return .send(.delegate(.tappedBackButton(state.beforeViewState)))
                
            case .viewEvent(.searchOnSubmit):
                let searchText = state.searchText
                let userLocation = state.userLocation
                
                if state.beforeViewState == .home {
                    if !state.searchText.isEmpty {
                        return .run { [state = state] send in
                            await send(.networkType(.searchSpot(page: 0, filter: state.filter, scroll: false, userLocation: userLocation)))
                        }
                    } else {
                        state.searchResult = false
                    }
                } else {
                    return .send(.delegate(.successSearch(searchText, state.beforeViewState)))
                }
                
            case .viewEvent(.searchStart):
                state.searchText = ""
                state.scrollToTop = false
                state.viewState = .search
                state.searchResult = true
                
            case let .viewEvent(.tappedSpotDetail(spotId, index)):
                state.selectSpotIndex = index
                state.scrollToTop = false
                return .send(.delegate(.tappedSpotDetail(spotId)))
                
            case let .viewEvent(.tappedArchiveButton(index)):
                return .run { send in
                    await send(.networkType(.patchArchiveState(index)))
                }
                
            case .viewEvent(.reset):
                state.searchResult = true
                
            case .viewEvent(.nextPage):
                state.listLoadTrigger = false
                
                let userLocation = state.userLocation
                let currentPage = state.currentPage
                let filter = state.filter
                
                return .run { send in
                    await send(.networkType(.searchSpot(page: currentPage + 1, filter: filter, scroll: true, userLocation: userLocation)))
                }
                
            case let .viewEvent(.dismissFilter(text)):
                state.filterIsvalid = false
                state.filterText = text
                state.filter = FilterCase.getFilter(text: text)
                
                state.currentPage = 0
                state.pageTotalCount = 0
                
                let currentPage = state.currentPage
                let filter = state.filter
                let userLocation = state.userLocation
                
                return .run { send in
                    await send(
                        .networkType(
                            .searchSpot(
                                page: currentPage,
                                filter: filter,
                                scroll: false, userLocation: userLocation
                            )
                        )
                    )
                }
                
            case .viewEvent(.openFilter):
                state.filterIsvalid = true
                
            case .delegate(.deletePop):
                state.scrollToTop = true
                state.currentPage = 0
                
                let userLocation = state.userLocation
                let filter = state.filter
                
                return .run { send in
                    await send(.networkType(.searchSpot(page: 0, filter: filter, scroll: false, userLocation: userLocation)))
                }
                
            case let .delegate(.detailBack(isArchive)):
                if state.searchSpotItems[state.selectSpotIndex].isScraped != isArchive {
                    state.searchSpotItems[state.selectSpotIndex] = SearchSpotEntity(
                        spotId: state.searchSpotItems[state.selectSpotIndex].spotId,
                        spotName: state.searchSpotItems[state.selectSpotIndex].spotName,
                        imageUrl: state.searchSpotItems[state.selectSpotIndex].imageUrl,
                        spotScraps: state.searchSpotItems[state.selectSpotIndex].spotScraps,
                        isScraped: isArchive,
                        reviews: state.searchSpotItems[state.selectSpotIndex].reviews,
                        distance: state.searchSpotItems[state.selectSpotIndex].distance
                    )
                }
                
            case let .networkType(.searchSpot(page, filer, scroll, userLocation)):
                return .run { [state = state] send in
                    do {
                        let data = try await spotRepository.fetchSearch(searchText: state.searchText, page: page, latitude: userLocation.latitude, longitude: userLocation.longitude, sortBy: filer)
                        
                        await send(.dataTransType(.searchSpot(data, scroll)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                        await send(.dataTransType(.error))
                    }
                }
                
            case let .networkType(.patchArchiveState(index)):
                let spotId = [state.searchSpotItems[index].spotId]
                
                return .run { send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: spotId)
                        
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
                        state.currentPage = data.currentPage
                        state.searchSpotItems.append(contentsOf: data.spots)
                        state.listLoadTrigger = true
                    } else {
                        state.viewState = .searchResult
                        
                        state.searchResult = true
                        state.itemTotalCount = data.totalCount
                        state.pageTotalCount = data.totalPages
                        state.currentPage = data.currentPage
                        state.searchSpotItems = data.spots
                        state.listLoadTrigger = true
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
                
            case let .bindingSearchText(text):
                state.searchText = text
                
            case let .bindingFilterIsValid(isValid):
                state.filterIsvalid = isValid
                
            default:
                break
            }
            return .none
        }
    }
}
