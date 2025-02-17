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
}

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.spotMap(SpotMapFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<MapScreen.State>>
        var isHideTabBar: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MapScreen>)
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
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .map, mbrLocation: mbrLocation)))
                
            case let .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedSpotAddButton(coord))))):
                state.isHideTabBar = true
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(spotCoord: coord)))
                
            case .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedMarker)))):
                state.isHideTabBar = true
                
            case .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.bottomSheetDismiss)))):
                state.isHideTabBar = false
                
            case .router(.routeAction(id: .spotMap, action: .spotMap(.delegate(.tappedSearch)))):
                state.isHideTabBar = true
                state.routes.push(.search(SearchFeature.State(beforeViewState: .map)))
                
            case .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case let .router(.routeAction(id: .search, action: .search(.delegate(.successSearch(searchText))))):
                state.isHideTabBar = true
                state.routes.push(.searchMap(SearchMapFeature.State(searchText: searchText)))
                
            case .router(.routeAction(id: .search, action: .search(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.tappedBackButton)))):
                state.isHideTabBar = true
                state.routes.pop()
                
            case .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.tappedXButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                
            case .router(.routeAction(id: .spotEditorView, action: .spotEditorView(.delegate(.successSpotAdd)))):
                state.isHideTabBar = true
                state.routes.push(.successView(SuccessFeature.State()))
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSearch)))):
                state.isHideTabBar = true
                state.routes.pop()
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.bottomSheetDismiss)))):
                state.isHideTabBar = true
                
            case let .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSideButton(mbrLocation))))):
                state.isHideTabBar = true
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .map, mbrLocation: mbrLocation)))
                
            case let .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedSpotAddButton(coord))))):
                state.isHideTabBar = true
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(spotCoord: coord)))
                
            case .router(.routeAction(id: .searchMap, action: .searchMap(.delegate(.tappedMarker)))):
                state.isHideTabBar = true
                
            case .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedBackButton)))):
                if state.routes.contains(where: { $0.id == .searchMap }) {
                    state.isHideTabBar = true
                } else {
                    state.isHideTabBar = false
                }
                state.routes.pop()
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedAddConfirmButton(spotCoord, spotAddress))))):
                state.routes.push(.spotEditorView(SpotEditorFeature.State(viewState: .add, spotLocation: spotCoord, spotAddress: spotAddress)))
                
            case .router(.routeAction(id: .successView, action: .successView(.delegate(.tappedConfirmButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
