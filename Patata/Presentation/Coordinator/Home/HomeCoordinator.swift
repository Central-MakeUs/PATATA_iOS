//
//  HomeCoordinator.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum HomeScreen {
    case home(PatataMainFeature)
    case search(SearchFeature)
    case category(SpotCategoryFeature)
    case spotDetail(SpotDetailFeature)
    case mySpotList(MySpotListFeature)
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
    case report(ReportFeature)
}

@Reducer
struct HomeCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.home(PatataMainFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<HomeScreen.State>>
        
        var popupIsPresent: Bool = false
        var isHideTabBar: Bool = false
        var alertIsPresent: Bool = false
        var errorMSG: String = ""
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<HomeScreen>)
        
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

extension HomeCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedSearch)))):
                state.isHideTabBar = true
                state.routes.push(.search(SearchFeature.State(beforeViewState: .home)))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedAddButton)))):
                state.isHideTabBar = true
                state.routes.push(.category(SpotCategoryFeature.State(initialIndex: 0)))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.tappedSpot(spotId))))):
                state.isHideTabBar = true
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .home, spotId: spotId)))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedMoreButton)))):
                state.isHideTabBar = true
                
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .home, mbrLocation: MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0)), isSearch: false, searchText: "")))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.tappedCategoryButton(category))))):
                state.isHideTabBar = true
                state.routes.push(.category(SpotCategoryFeature.State(initialIndex: category.rawValue)))
                
            case .router(.routeAction(id: .search, action: .search(.delegate(.tappedBackButton(_))))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case let .router(.routeAction(id: .search, action: .search(.delegate(.tappedSpotDetail(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .search, spotId: spotId)))
                
            case .router(.routeAction(id: .category, action: .category(.delegate(.tappedNavBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case let .router(.routeAction(id: .category, action: .category(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete(viewState))))):
                state.routes.pop()
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
                if viewState == .home {
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
                }
                
                if viewState == .search {
                    return .send(.router(.routeAction(id: .search, action: .search(.delegate(.deletePop)))))
                } else if viewState == .other {
                    return .send(.router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.delete)))))
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.deleteSpot(msg, viewState))))):
                state.routes.pop()
                state.errorMSG = msg
                state.popupIsPresent = true
                
                if viewState == .home {
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
                }
                
                if viewState == .search {
                    return .send(.router(.routeAction(id: .search, action: .search(.delegate(.deletePop)))))
                } else if viewState == .other {
                    return .send(.router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.delete)))))
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton(archive, viewState))))):
                state.routes.pop()
                
                if viewState == .home {
                    state.isHideTabBar = false
                }
                
                if viewState == .search {
                    return .send(.router(.routeAction(id: .search, action: .search(.delegate(.detailBack(archive))))))
                }
            
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.report(type, id))))):
                if type == "Post" {
                    state.routes.push(.report(ReportFeature.State(viewState: .post, id: id)))
                } else {
                    state.routes.push(.report(ReportFeature.State(viewState: .user, id: id)))
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.reviewReport(id))))):
                state.routes.push(.report(ReportFeature.State(viewState: .review, id: id)))
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.editSpotDetail(spotDetail, _))))):
                state.routes.push(.spotedit(SpotEditorFeature.State(viewState: .edit, spotDetail: spotDetail, spotLocation: spotDetail.spotCoord, spotAddress: spotDetail.spotAddress, imageDatas: [], beforeViewState: .other)))
                
            case .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedBackButton(_))))):
                state.routes.pop()
                state.isHideTabBar = false
                
            case let .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedBackButton)))):
                state.routes.pop()
                state.isHideTabBar = true
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedXButton)))):
                state.routes.popToRoot()
                state.isHideTabBar = false
                
            case let .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedLocation(coord, _, spotDetail, _))))):
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotDetailEntity: spotDetail, datas: [], spotCoord: coord)))
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.successSpotEdit)))):
                state.errorMSG = "게시물이 수정되었습니다."
                state.routes.pop()
                state.popupIsPresent = true
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddress, _, _, _))))):
                state.routes.pop()
                
                return .run { send in
                    await send(.router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.changeAddress(coord, spotAddress))))))
                }
                
            case .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedBackButton(_))))):
                state.routes.pop()
                
            case .router(.routeAction(id: .report, action: .report(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .report, action: .report(.delegate(.tappedConfirmButton)))):
                state.alertIsPresent = true
                state.routes.popToRoot()
                
                if state.routes.count == 1 {
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
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
