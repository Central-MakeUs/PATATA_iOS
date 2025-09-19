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
        
        var root: PatataMainFeature.State = .init()
        var spotArchive: Bool = false
        var changeArchive: Bool = false
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
        case root(PatataMainFeature.Action)
        
        case viewEvent(ViewEventType)
        case onAppear
        case changeIsHidden
        case bindingPopupIsPresent(Bool)
        case bindingAlertIsPrenset(Bool)
    }
    
    enum ViewEventType {
        case dismissPopup
        case dismissAlert
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root) {
            PatataMainFeature()
        }
        
        core()
            .forEach(\.routes, action: \.router)
    }
}

extension HomeCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.screenIds[.home] = state.routes.ids.last
                
            case let .router(.element(_, action)):
                return routerAction(state: &state, action: action)
                
            case .changeIsHidden:
                if state.routes.count == 1 || state.routes.isEmpty {
                    changeIsHidden(false, &state)
                } else {
                    changeIsHidden(true, &state)
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
    }
    
    private func routerAction(state: inout HomeCoordinator.State, action: HomeCoordPath.Action) -> Effect<Action> {
        switch action {
        case let .home(.delegate(action)):
            return homeAction(state: &state, action: action)
            
        case let .search(.delegate(action)):
            return searchAction(state: &state, action: action)
            
        case let .category(.delegate(action)):
            return categoryAction(state: &state, action: action)
            
        case let .spotDetail(.delegate(action)):
            return spotDetailAction(state: &state, action: action)
            
        case let .mySpotList(.delegate(action)):
            return mySpotListAction(state: &state, action: action)
        case let .spotedit(.delegate(action)):
            return spotEditAction(state: &state, action: action)
            
        case let .addSpotMap(.delegate(action)):
            return addSpotAction(state: &state, action: action)
            
        case let .report(.delegate(action)):
            return reportAction(state: &state, action: action)
            
        default:
            break
        }
        
        return .none
    }
    
    private func homeAction(state: inout HomeCoordinator.State, action: PatataMainFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedSearch:
            state.routes.append(.search(SearchFeature.State(beforeViewState: .home)))
            state.screenIds[.search] = state.routes.ids.last
            
        case .tappedAddButton:
            state.routes.append(.category(SpotCategoryFeature.State(initialIndex: 0)))
            state.screenIds[.category] = state.routes.ids.last
            
        case let .tappedSpot(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .home, spotId: spotId)))
            state.screenIds[.spotDetail] = state.routes.ids.last
            
        case .tappedMoreButton:
            state.routes.append(
                .mySpotList(
                    MySpotListFeature.State(
                        viewState: .home,
                        mbrLocation: MBRCoordinates(
                            northEast: Coordinate(
                                latitude: 0,
                                longitude: 0
                            ),
                            southWest: Coordinate(latitude: 0, longitude: 0)
                        ),
                        isSearch: false,
                        searchText: ""
                    )
                )
            )
            state.screenIds[.mySpotList] = state.routes.ids.last
            
        case let .tappedCategoryButton(category):
            state.routes.append(.category(SpotCategoryFeature.State(initialIndex: category.rawValue)))
            state.screenIds[.category] = state.routes.ids.last
            
        }
        
        return .none
    }
    
    private func searchAction(state: inout HomeCoordinator.State, action: SearchFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedBackButton(_):
            _ = state.routes.popLast()
            
        case let .tappedSpotDetail(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .search, spotId: spotId)))
            state.screenIds[.spotDetail] = state.routes.ids.last
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        default:
            break
        }
        
        return .none
    }
    
    private func categoryAction(state: inout HomeCoordinator.State, action: SpotCategoryFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedNavBackButton:
            _ = state.routes.popLast()
            
        case let .tappedSpot(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        case let .tappedArchive(spotId, archive):
            if let homeId = state.screenIds[.home] {
                return .send(.router(.element(id: homeId, action: .home(.parentsAction(.archiveSpot(spotId, archive))))))
            }
        }
        
        return .none
    }
    
    private func spotDetailAction(state: inout HomeCoordinator.State, action: SpotDetailFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedNavBackButton(archive, viewState):
            _ = state.routes.popLast()
            
            if viewState == .home {
                state.$isHidden.withLock { $0 = false }
            }
            
            if viewState == .search {
                if let searchId = state.screenIds[.search] {
                    return .send(.router(.element(id: searchId, action: .search(.delegate(.detailBack(archive))))))
                }
            }
            
        case let .delete(viewState):
            _ = state.routes.popLast()
            state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
            state.popupIsPresent = true
            
            if viewState == .search {
                if let searchId = state.screenIds[.search] {
                    return .send(.router(.element(id: searchId, action: .search(.parentsAction(.deletePop)))))
                }
            } else if viewState == .other {
                if let mySpotListId = state.screenIds[.mySpotList] {
                    return .send(.router(.element(id: mySpotListId, action: .mySpotList(.parentsAction(.delete)))))
                }
            }
            
        case let .editSpotDetail(spotDetail, _):
            state.routes.append(
                .spotedit(
                    SpotEditorFeature.State(
                        viewState: .edit,
                        spotDetail: spotDetail,
                        spotLocation: spotDetail.spotCoord,
                        spotAddress: spotDetail.spotAddress,
                        imageDatas: [],
                        beforeViewState: .other
                    )
                )
            )
            state.screenIds[.spotedit] = state.routes.ids.last
            
        case let .report(type, id):
            if type == "Post" {
                state.routes.append(.report(ReportFeature.State(viewState: .post, id: id)))
                state.screenIds[.report] = state.routes.ids.last
            } else {
                state.routes.append(.report(ReportFeature.State(viewState: .post, id: id)))
                state.screenIds[.report] = state.routes.ids.last
            }
            
        case let .reviewReport(id):
            state.routes.append(.report(ReportFeature.State(viewState: .review, id: id)))
            state.screenIds[.report] = state.routes.ids.last
            
        case let .deleteSpot(msg, viewState):
            _ = state.routes.popLast()
            state.errorMSG = msg
            state.popupIsPresent = true
            
            if viewState == .search {
                if let searchId = state.screenIds[.search] {
                    return .send(.router(.element(id: searchId, action: .search(.parentsAction(.deletePop)))))
                }
            } else if viewState == .other {
                if let mySpotListId = state.screenIds[.mySpotList] {
                    return .send(.router(.element(id: mySpotListId, action: .mySpotList(.parentsAction(.delete)))))
                }
            }
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        case let .changeArchive(spotId, bool, viewState):
            if let homeId = state.screenIds[.home] {
                if let categoryId = state.screenIds[.category] {
                    return .merge([
                        .send(.router(.element(id: categoryId, action: .category(.parentsAction(.changeArchive(bool)))))),
                        .send(.router(.element(id: homeId, action: .home(.parentsAction(.archiveSpot(spotId, bool))))))
                    ])
                }
                
                if let searchId = state.screenIds[.search] {
                    return .merge([
                        .send(.router(.element(id: searchId, action: .search(.parentsAction(.changeArchive(spotId, bool)))))),
                        .send(.router(.element(id: homeId, action: .home(.parentsAction(.archiveSpot(spotId, bool))))))
                    ])
                }
                
                return .send(.router(.element(id: homeId, action: .home(.parentsAction(.archiveSpot(spotId, bool))))))
            }
            
        case let .fetchData(isArchive, _):
            if let categoryId = state.screenIds[.category] {
                return .send(.router(.element(id: categoryId, action: .category(.parentsAction(.changeArchive(isArchive))))))
            }
            
        }
        
        return .none
    }
    
    private func mySpotListAction(state: inout HomeCoordinator.State, action: MySpotListFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedBackButton(_):
            _ = state.routes.popLast()
            
        case let .tappedSpot(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
            state.screenIds[.spotDetail] = state.routes.ids.last
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        case let .changeArchive(spotId, archive):
            if let homeId = state.screenIds[.home] {
                return .send(.router(.element(id: homeId, action: .home(.parentsAction(.archiveSpot(spotId, archive))))))
            }
            
        default:
            break
        }
        
        return .none
    }
    
    private func spotEditAction(state: inout HomeCoordinator.State, action: SpotEditorFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedBackButton:
            _ = state.routes.popLast()
            
        case .tappedXButton:
            if let rootId = state.routes.ids.first {
                state.routes.pop(to: rootId)
            }
            
        case let .tappedLocation(coord, _, spotDetail, _):
            state.routes.append(
                .addSpotMap(
                    AddSpotMapFeature.State(
                        viewState: .edit,
                        spotDetailEntity: spotDetail,
                        datas: [],
                        spotCoord: coord
                    )
                )
            )
            state.screenIds[.addSpotMap] = state.routes.ids.last
            
        case .successSpotEdit(_):
            state.errorMSG = "게시물이 수정되었습니다."
            _ = state.routes.popLast()
            state.popupIsPresent = true
            
        default:
            break
        }
        
        return .none
    }
    
    private func addSpotAction(state: inout HomeCoordinator.State, action: AddSpotMapFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedBackButton(_):
            _ = state.routes.popLast()
            
        case let .tappedAddConfirmButton(coord, spotAddress, _, _, _):
            _ = state.routes.popLast()
            
            if let spotEditId = state.screenIds[.spotedit] {
                return .run { send in
                    await send(.router(.element(id: spotEditId, action: .spotedit(.parentsAction(.changeAddress(coord, spotAddress))))))
                }
            }
            
        default:
            break
        }
        
        return .none
    }
    
    private func reportAction(state: inout HomeCoordinator.State, action: ReportFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedConfirmButton:
            state.alertIsPresent = true
            
            if let rootId = state.routes.ids.first {
                state.routes.pop(to: rootId)
            }
            
        case .tappedBackButton:
            _ = state.routes.popLast()
        }
        
        return .none
    }
    
}

extension HomeCoordinator {
    private func changeIsHidden(_ isHidden: Bool, _ state: inout State) {
        state.$isHidden.withLock { $0 = isHidden }
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
