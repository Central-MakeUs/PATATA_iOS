//
//  HomeCoordinator.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        @Shared var isHidden: Bool
        
        var routes: StackState<HomeCoordPath.State> = .init([
            .home(PatataMainFeature.State())
        ])
        
        var popupIsPresent: Bool = false
        var alertIsPresent: Bool = false
        var errorMSG: String = ""
        var screenIds: [ScreenType: StackElementID] = [:]
        
        init(isHidden: @autoclosure () -> Bool = false) {
            self._isHidden = Shared(wrappedValue: isHidden(), .inMemory("isHidden"))
        }
    }
    
    enum Action {
        case router(StackActionOf<HomeCoordPath>)
        
        case viewEvent(ViewEventType)
        case bindingPopupIsPresent(Bool)
        case bindingAlertIsPrenset(Bool)
    }
    
    enum ViewEventType {
        case dismissPopup
        case dismissAlert
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.element(id: _, action: .home(.delegate(.tappedSearch)))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.search(SearchFeature.State(beforeViewState: .home)))
                state.screenIds[.search] = state.routes.ids.last
                
            case .router(.element(id: _, action: .home(.delegate(.tappedAddButton)))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.category(SpotCategoryFeature.State(initialIndex: 0)))
                state.screenIds[.category] = state.routes.ids.last

            case let .router(.element(id: _, action: .home(.delegate(.tappedSpot(spotId))))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .home, spotId: spotId)))
                state.screenIds[.spotDetail] = state.routes.ids.last
                
            case .router(.element(id: _, action: .home(.delegate(.tappedMoreButton)))):
                state.$isHidden.withLock { $0 = true }
                
                state.routes.append(.mySpotList(MySpotListFeature.State(viewState: .home, mbrLocation: MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0)), isSearch: false, searchText: "")))
                state.screenIds[.mySpotList] = state.routes.ids.last
                
            case let .router(.element(id: _, action: .home(.delegate(.tappedCategoryButton(category))))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.category(SpotCategoryFeature.State(initialIndex: category.rawValue)))
                state.screenIds[.category] = state.routes.ids.last
                
            case .router(.element(id: _, action: .search(.delegate(.tappedBackButton(_))))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()
                
            case let .router(.element(id: _, action: .search(.delegate(.tappedSpotDetail(spotId))))):
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .search, spotId: spotId)))
                state.screenIds[.spotDetail] = state.routes.ids.last
                
            case  .router(.element(id: _, action: .category(.delegate(.tappedNavBackButton)))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()

            case let .router(.element(id: _, action: .category(.delegate(.tappedSpot(spotId))))):
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                state.screenIds[.spotDetail] = state.routes.ids.last
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.delete(viewState))))):
                _ = state.routes.popLast()
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
                if viewState == .home {
                    state.$isHidden.withLock { $0 = false }
                } else {
                    state.$isHidden.withLock { $0 = true }
                }
                
                if viewState == .search {
                    if let searchId = state.screenIds[.search] {
                        return .send(.router(.element(id: searchId, action: .search(.parentsAction(.deletePop)))))
                    }
                } else if viewState == .other {
                    if let mySpotListId = state.screenIds[.mySpotList] {
                        return .send(.router(.element(id: mySpotListId, action: .mySpotList(.parentsAction(.delete)))))
                    }
                }
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.deleteSpot(msg, viewState))))):
                _ = state.routes.popLast()
                state.errorMSG = msg
                state.popupIsPresent = true
                
                if viewState == .home {
                    state.$isHidden.withLock { $0 = false }
                } else {
                    state.$isHidden.withLock { $0 = true }
                }
                
                if viewState == .search {
                    if let searchId = state.screenIds[.search] {
                        return .send(.router(.element(id: searchId, action: .search(.parentsAction(.deletePop)))))
                    }
                } else if viewState == .other {
                    if let mySpotListId = state.screenIds[.mySpotList] {
                        return .send(.router(.element(id: mySpotListId, action: .mySpotList(.parentsAction(.delete)))))
                    }
                }
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.tappedNavBackButton(archive, viewState))))):
                _ = state.routes.popLast()
                
                if viewState == .home {
                    state.$isHidden.withLock { $0 = false }
                }
                
                if viewState == .search {
                    if let searchId = state.screenIds[.search] {
                        return .send(.router(.element(id: searchId, action: .search(.delegate(.detailBack(archive))))))
                    }
                }
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.report(type, id))))):
                if type == "Post" {
                    state.routes.append(.report(ReportFeature.State(viewState: .post, id: id)))
                    state.screenIds[.report] = state.routes.ids.last
                } else {
                    state.routes.append(.report(ReportFeature.State(viewState: .post, id: id)))
                    state.screenIds[.report] = state.routes.ids.last
                }
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.reviewReport(id))))):
                state.routes.append(.report(ReportFeature.State(viewState: .review, id: id)))
                state.screenIds[.report] = state.routes.ids.last
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.editSpotDetail(spotDetail, _))))):
                state.routes.append(.spotedit(SpotEditorFeature.State(viewState: .edit, spotDetail: spotDetail, spotLocation: spotDetail.spotCoord, spotAddress: spotDetail.spotAddress, imageDatas: [], beforeViewState: .other)))
                state.screenIds[.spotedit] = state.routes.ids.last
                
            case .router(.element(id: _, action: .mySpotList(.delegate(.tappedBackButton(_))))):
                _ = state.routes.popLast()
                state.$isHidden.withLock { $0 = false }
                
            case let .router(.element(id: _, action: .mySpotList(.delegate(.tappedSpot(spotId))))):
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                state.screenIds[.spotDetail] = state.routes.ids.last
                
            case .router(.element(id: _, action: .spotedit(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()
                state.$isHidden.withLock { $0 = true }
                
            case .router(.element(id: _, action: .spotedit(.delegate(.tappedXButton)))):
                if let rootId = state.routes.ids.first {
                    state.routes.pop(to: rootId)
                    state.$isHidden.withLock { $0 = false }
                }
                
            case let .router(.element(id: _, action: .spotedit(.delegate(.tappedLocation(coord, _, spotDetail, _))))):
                state.routes.append(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotDetailEntity: spotDetail, datas: [], spotCoord: coord)))
                state.screenIds[.addSpotMap] = state.routes.ids.last
                
            case .router(.element(id: _, action: .spotedit(.delegate(.successSpotEdit(_))))):
                state.errorMSG = "게시물이 수정되었습니다."
                _ = state.routes.popLast()
                state.popupIsPresent = true
                
            case let .router(.element(id: _, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddress, _, _, _))))):
                _ = state.routes.popLast()
                
                if let spotEditId = state.screenIds[.spotedit] {
                    return .run { send in
                        await send(.router(.element(id: spotEditId, action: .spotedit(.parentsAction(.changeAddress(coord, spotAddress))))))
                    }
                }
                
            case .router(.element(id: _, action: .addSpotMap(.delegate(.tappedBackButton(_))))):
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .report(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .report(.delegate(.tappedConfirmButton)))):
                state.alertIsPresent = true
                
                if let rootId = state.routes.ids.first {
                    state.routes.pop(to: rootId)
                }
                
                if state.routes.count == 1 {
                    state.$isHidden.withLock { $0 = false }
                } else {
                    state.$isHidden.withLock { $0 = true }
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
            .forEach(\.routes, action: \.router)

    }
}

extension HomeCoordinator.State {
    enum ScreenType {
        case home
        case search
        case category
        case spotDetail
        case mySpotList
        case spotedit
        case addSpotMap
        case report
    }
    
    var homeId: StackElementID? {
        get { screenIds[.home] }
        set { screenIds[.home] = newValue }
    }
    
    var searchId: StackElementID? {
        get { screenIds[.search] }
        set { screenIds[.search] = newValue }
    }
    
    var categoryId: StackElementID? {
        get { screenIds[.category] }
        set { screenIds[.category] = newValue }
    }
    
    var spotDetailId: StackElementID? {
        get { screenIds[.spotDetail] }
        set { screenIds[.spotDetail] = newValue }
    }
    
    var mySpotListId: StackElementID? {
        get { screenIds[.mySpotList] }
        set { screenIds[.mySpotList] = newValue }
    }
    
    var spoteditId: StackElementID? {
        get { screenIds[.spotedit] }
        set { screenIds[.spotedit] = newValue }
    }
    
    var addSpotMapId: StackElementID? {
        get { screenIds[.addSpotMap] }
        set { screenIds[.addSpotMap] = newValue }
    }
    
    var reportId: StackElementID? {
        get { screenIds[.report] }
        set { screenIds[.report] = newValue }
    }
}
