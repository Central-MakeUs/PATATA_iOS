//
//  MapCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

// 바텀 시트가 올라올때 이지역에서 탐색 버튼이 필요없을거 같다 어차피 지도랑 상호작용(유저가 좌표를 이동해서 지역 탐색을 하지 못할거 같다)을 못해서 필요하지가 않다
// 그리고 내 현재 위치의 버튼도 필요가 없을거 같다
// 왜냐하면 바텀시트가 올라오는 이벤트 시점은 유저가 보이는 화면의 마커를 눌렀을때 나오는데
// 서치후 화면을 보여줄때 탭을 숨기는게 맞다고 본다
// 서치후 화면에서 서치 추가를 끝낸후에는 부모 뷰로 갈껀지? 아니면 서치 후 나오는 화면으로 갈껀지 그럼 다시 돌아왔을때 처음 검색어에 대한 바텀시트를 계속 띄운 상태로 다시 돌아올건지

@Reducer(state: .equatable)
enum MapScreen {
    case spotMap(SpotMapFeature)
    case mySpotList(MySpotListFeature)
    case spotEditorView(SpotEditorFeature)
    case search(SearchFeature)
    case searchMap(SearchMapFeature)
    case addSpotMap(AddSpotMapFeature)
    case successView(SuccessFeature)
    case spotDetail(SpotDetailFeature)
    case report(ReportFeature)
}

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.spotMap(SpotMapFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<MapScreen.State>>
        
        var isHideTabBar: Bool = false
        var popupIsPresent: Bool = false
        var errorMSG: String = ""
        var alertIsPresent: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MapScreen>)
        
        case viewEvent(ViewEventType)
        
        case bindingPopupIsPresent(Bool)
        case bindingAlertIsPrenset(Bool)
    }
    
    enum ViewEventType {
        case dismissPopup
        case dismissAlert
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MapCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedSideButton(mbrLocation))))):
                state.isHideTabBar = true
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .map, mbrLocation: mbrLocation, isSearch: false, searchText: "")))
                
            case let .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedSpotAddButton(coord))))):
                state.isHideTabBar = true
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .map, spotCoord: coord)))
                
            case .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedMarker)))):
                state.isHideTabBar = true
                
            case .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.bottomSheetDismiss)))):
                state.isHideTabBar = false
                
            case .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedSearch)))):
                state.isHideTabBar = true
                state.routes.push(.search(SearchFeature.State(beforeViewState: .map)))
                
            case let .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedSpotDetail(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .map, spotId: spotId)))
                
            case let .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedBackButton(viewState))))):
                if viewState == .map {
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
                }
                
                state.routes.pop()
                
            case let .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedSearch(viewState))))):
                if viewState == .mapSearch {
                    state.routes.remove(id: .search)
                    state.routes.push(.search(SearchFeature.State(beforeViewState: .searchMap)))
                } else {
                    state.routes.push(.search(SearchFeature.State(beforeViewState: .mySpotList)))
                }
                
                
            case let .router(.routeAction(id: .search, action: .search(.delegate(.successSearch(searchText, viewState))))):
                state.isHideTabBar = true
                
                if viewState == .searchMap {
                    state.routes.popTo(id: .searchMap)
                    
                    return .run { send in
                        await send(.router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.mySpotListSearch(searchText))))))
                    }
                } else if viewState == .mySpotList {
                    state.routes.remove(id: .mySpotList)
                    state.routes.push(.searchMap(SearchMapFeature.State(searchText: searchText)))
                } else {
                    state.routes.push(.searchMap(SearchMapFeature.State(searchText: searchText)))
                }
                
            case let .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                
            case let .router(.routeAction(id: .search, action: .search(.delegate(.tappedBackButton(viewState))))):
                
                if viewState == .mySpotList {
                    state.isHideTabBar = true
                } else {
                    state.isHideTabBar = false
                }
                
                state.routes.pop()
                
            case .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.tappedBackButton)))):
                state.isHideTabBar = true
                state.routes.pop()
                
            case .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.tappedXButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                
            case .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.successSpotAdd)))):
                state.isHideTabBar = true
                state.routes.push(.successView(SuccessFeature.State(viewState: .spot)))
                
            case let .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.tappedLocation(coord, viewState))))):
                if viewState == .edit {
                    state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotCoord: coord)))
                } else {
                    state.routes.pop()
                }
                
            case let .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.successSpotEdit(viewState))))):
                state.errorMSG = "게시물이 수정되었습니다."
                state.routes.pop()
                state.popupIsPresent = true
                
                if viewState == .searchMap {
                    return .send(.router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.successEdit)))))
                } else {
                    return .send(.router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.successEdit)))))
                }
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSearch)))):
                state.isHideTabBar = true
                state.routes.pop()
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.bottomSheetDismiss)))):
                state.isHideTabBar = true
                
            case let .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSideButton(mbrLocation, searchText, isSearch))))):
                state.isHideTabBar = true
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .mapSearch, mbrLocation: mbrLocation, isSearch: isSearch, searchText: searchText)))
                
            case let .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSpotAddButton(coord))))):
                state.isHideTabBar = true
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .searchMap, spotCoord: coord)))
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedMarker)))):
                state.isHideTabBar = true
                
            case let .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSpotDetail(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .mapSearch, spotId: spotId)))
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedBackButton(viewState))))):
                if viewState == .map {
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
                }
                
                state.routes.pop()
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedAddConfirmButton(spotCoord, spotAddress, viewState))))):
                if viewState == .map || viewState == .searchMap {
                    state.routes.push(.spotEditorView(SpotEditorFeature.State(viewState: .add, spotDetail: SpotDetailEntity(), spotLocation: spotCoord, spotAddress: spotAddress, beforeViewState: .map)))
                } else {
                    state.routes.pop()
                    return .run { send in
                        await send(.router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.changeAddress(spotCoord, spotAddress))))))
                    }
                }
                
            case .router(.routeAction(id: .successView, action: .successView(.delegate(.tappedConfirmButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton(_, viewState))))):
                state.isHideTabBar = true
                state.routes.pop()
                
                if viewState == .mapSearch {
                    return .send(.router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.detailBack)))))
                } else if viewState == .map {
                    return .send(.router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.detailBack)))))
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.editSpotDetail(spotDetail, viewState))))):
                if viewState == .map {
                    state.routes.push(.spotEditorView(SpotEditorFeature.State(viewState: .edit, spotDetail: spotDetail, spotLocation: Coordinate(latitude: 0, longitude: 0), spotAddress: spotDetail.spotAddress, beforeViewState: .map)))
                } else if viewState == .mapSearch {
                    state.routes.push(.spotEditorView(SpotEditorFeature.State(viewState: .edit, spotDetail: spotDetail, spotLocation: Coordinate(latitude: 0, longitude: 0), spotAddress: spotDetail.spotAddress, beforeViewState: .searchMap)))
                } else {
                    state.routes.push(.spotEditorView(SpotEditorFeature.State(viewState: .edit, spotDetail: spotDetail, spotLocation: Coordinate(latitude: 0, longitude: 0), spotAddress: spotDetail.spotAddress, beforeViewState: .other)))
                }
                
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.report(type, id))))):
                if type == "Post" {
                    state.routes.push(.report(ReportFeature.State(viewState: .post, id: id)))
                } else {
                    state.routes.push(.report(ReportFeature.State(viewState: .user, id: id)))
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.reviewReport(id))))):
                state.routes.push(.report(ReportFeature.State(viewState: .review, id: id)))
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete(viewState))))):
                if viewState == .map {
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
                }
                
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
                state.routes.pop()
                
                if viewState == .map {
                    return .run { send in
                        await send(.router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.deleteSpot)))))
                    }
                } else if viewState == .mapSearch {
                    return .run { send in
                        await send(.router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.deleteSpot)))))
                    }
                }
                
            case .router(.routeAction(id: .report, action: .report(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .report, action: .report(.delegate(.tappedConfirmButton)))):
                state.routes.popToRoot()
                state.alertIsPresent = true
                state.isHideTabBar = false
                
                return .run { send in
                    await send(.router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.deleteSpot)))))
                }
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case .viewEvent(.dismissAlert):
                state.alertIsPresent = false
                
            case let .bindingPopupIsPresent(isPresent):
                state.popupIsPresent = isPresent
                
            case let .bindingAlertIsPrenset(isPresent):
                state.alertIsPresent = isPresent
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
