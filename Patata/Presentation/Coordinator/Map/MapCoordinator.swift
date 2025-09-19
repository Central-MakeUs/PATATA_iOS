//
//  MapCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import Foundation
import ComposableArchitecture

// 바텀 시트가 올라올때 이지역에서 탐색 버튼이 필요없을거 같다 어차피 지도랑 상호작용(유저가 좌표를 이동해서 지역 탐색을 하지 못할거 같다)을 못해서 필요하지가 않다
// 그리고 내 현재 위치의 버튼도 필요가 없을거 같다
// 왜냐하면 바텀시트가 올라오는 이벤트 시점은 유저가 보이는 화면의 마커를 눌렀을때 나오는데
// 서치후 화면을 보여줄때 탭을 숨기는게 맞다고 본다
// 서치후 화면에서 서치 추가를 끝낸후에는 부모 뷰로 갈껀지? 아니면 서치 후 나오는 화면으로 갈껀지 그럼 다시 돌아왔을때 처음 검색어에 대한 바텀시트를 계속 띄운 상태로 다시 돌아올건지

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        @Shared var isHidden: Bool
        
        var routes: StackState<MapCoordPath.State> = .init()
        var root: SpotMapFeature.State = .init()
        var screenIds: [ScreenType: StackElementID] = [:]
        
        var popupIsPresent: Bool = false
        var errorMSG: String = ""
        var alertIsPresent: Bool = false
        var isPresent: Bool = false
        
        init(isHidden: @autoclosure () -> Bool = false) {
            self._isHidden = Shared(wrappedValue: isHidden(), .inMemory("isHidden"))
        }
    }
    
    enum Action {
        case router(StackActionOf<MapCoordPath>)
        case root(SpotMapFeature.Action)
        
        case viewCycle(ViewCycle)
        case viewEvent(ViewEventType)
        
        case bindingPopupIsPresent(Bool)
        case bindingAlertIsPrenset(Bool)
        
        enum ViewCycle {
            case disAppear
        }
    }
    
    enum ViewEventType {
        case dismissPopup
        case dismissAlert
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root) {
            SpotMapFeature()
        }
        
        core()
    }
}

extension MapCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .root(.delegate(root)):
                return rootAction(state: &state, action: root)
                
            case let .router(.element(_, action)):
                return routerAction(state: &state, action: action)
                
            case .viewCycle(.disAppear):
                if !state.isPresent {
                    if let id = state.screenIds[.searchMap] {
                        if state.routes.ids.last == id {
                            changeIsHidden(false, &state)
                        }
                    }
                    
                    if state.routes.isEmpty {
                        changeIsHidden(false, &state)
                    }
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

extension MapCoordinator {
    private func rootAction(state: inout State, action: SpotMapFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedSideButton(mbrLocation, isPresent):
            state.isPresent = isPresent
            state.routes.append(.mySpotList(MySpotListFeature.State(viewState: .map, mbrLocation: mbrLocation, isSearch: false, searchText: "")))
            state.screenIds[.mySpotList] = state.routes.ids.last
            
        case let .tappedSpotAddButton(coord, isPresent):
            state.isPresent = isPresent
            state.routes.append(.addSpotMap(AddSpotMapFeature.State(viewState: .map, spotDetailEntity: SpotDetailEntity(), datas: [], spotCoord: coord)))
            state.screenIds[.addSpotMap] = state.routes.ids.last
            
        case .tappedMarker:
            state.isPresent = true
            changeIsHidden(true, &state)
            
        case .bottomSheetDismiss:
            state.isPresent = false
            changeIsHidden(false, &state)
            
        case .tappedSearch:
            changeIsHidden(true, &state)
            state.routes.append(.search(SearchFeature.State(beforeViewState: .map)))
            state.screenIds[.search] = state.routes.ids.last
            
        case let .tappedSpotDetail(spotId, isPresent):
            state.isPresent = isPresent
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .map, spotId: spotId)))
            state.screenIds[.spotDetail] = state.routes.ids.last
            
        case .moveCamera:
            changeIsHidden(false, &state)
            
        default:
            break
        }
        
        return .none
    }
}

extension MapCoordinator {
    private func routerAction(state: inout State, action: MapCoordPath.Action) -> Effect<Action> {
        switch action {
        case let .mySpotList(.delegate(action)):
            return mySpotListAction(state: &state, action: action)
            
        case let .spotEditorView(.delegate(action)):
            return spotEditorAction(state: &state, action: action)
            
        case let .search(.delegate(action)):
            return searchAction(state: &state, action: action)
            
        case let .searchMap(.delegate(action)):
            return searchMapAction(state: &state, action: action)
            
        case let .addSpotMap(.delegate(action)):
            return addSpotMapAction(state: &state, action: action)
            
        case let .successView(.delegate(action)):
            return successAction(state: &state, action: action)
            
        case let .spotDetail(.delegate(action)):
            return spotDetailAction(state: &state, action: action)
            
        case let .report(.delegate(action)):
            return reportAction(state: &state, action: action)
            
        default:
            break
        }
        
        return .none
    }
}

extension MapCoordinator {
    private func mySpotListAction(state: inout State, action: MySpotListFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedBackButton(viewState):
            if viewState == .mapSearch {
                if let id = state.screenIds[.searchMap] {
                    return .send(.router(.element(id: id, action: .searchMap(.parentsAction(.detailBack)))))
                }
            }
            
            _ = state.routes.popLast()
            
        case let .tappedSpot(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
            
        case let .tappedSearch(viewState):
            if viewState == .mapSearch {
                
                if let id = state.screenIds[.search] {
                    state.routes.pop(from: id)
                }
                
                state.routes.append(.search(SearchFeature.State(beforeViewState: .searchMap)))
            } else {
                state.routes.append(.search(SearchFeature.State(beforeViewState: .mySpotList)))
            }
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        case let .changeArchive(spotId, archive):
            if let searchMapId = state.screenIds[.searchMap] {
                return .send(.router(.element(id: searchMapId, action: .searchMap(.parentsAction(.changeArchive(spotId, archive))))))
            }
            
            return .send(.root(.parentsAction(.changeArchive(spotId, archive))))
        }
        
        return .none
    }
    
    private func spotEditorAction(state: inout State, action: SpotEditorFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedBackButton:
            _ = state.routes.popLast()
            
            if let id = state.screenIds[.addSpotMap] {
                return .send(.router(.element(id: id, action: .addSpotMap(.parentsAction(.tappedEditorBackButton)))))
            }
            
        case .successSpotAdd:
            state.routes.append(.successView(SuccessFeature.State(viewState: .spot)))
            
        case .tappedXButton:
            state.routes.removeAll()
            
        case let .tappedLocation(coord, viewState, spotDetail, imageData):
            if viewState == .edit {
                state.routes.append(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotDetailEntity: spotDetail, datas: [], spotCoord: coord)))
            } else {
                _ = state.routes.popLast()
                
                if let id = state.screenIds[.addSpotMap] {
                    return .send(.router(.element(id: id, action: .addSpotMap(.parentsAction(.popEditorView(spotDetail, imageData))))))
                }
            }
            
        case let .successSpotEdit(viewState):
            state.errorMSG = "게시물이 수정되었습니다."
            _ = state.routes.popLast()
            state.popupIsPresent = true
            
            if viewState == .searchMap {
                if let id = state.screenIds[.searchMap] {
                    return .send(.router(.element(id: id, action: .searchMap(.parentsAction(.successEdit)))))
                }
            } else {
                return .send(.root(.parentsAction(.successEdit)))
            }
        }
        
        return .none
    }
    
    private func searchAction(state: inout State, action: SearchFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let.tappedBackButton(viewState):
            _ = state.routes.popLast()
            
        case let .successSearch(searchText, viewState):
            if viewState == .searchMap {
                
                if let id = state.screenIds[.searchMap] {
                    state.routes.pop(to: id)
                    
                    return .run { send in
                        await send(.router(.element(id: id, action: .searchMap(.parentsAction(.mySpotListSearch(searchText))))))
                    }
                }
            } else if viewState == .mySpotList {
                if let id = state.screenIds[.mySpotList] {
                    state.routes.pop(from: id)
                }
                state.routes.append(.searchMap(SearchMapFeature.State(searchText: searchText)))
            } else {
                state.routes.append(.searchMap(SearchMapFeature.State(searchText: searchText)))
            }
            
        default:
            break
        }
        
        return .none
    }
    
    private func searchMapAction(state: inout State, action: SearchMapFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedSideButton(mbrCoord, searchText, isSearch, isPresented):
            state.routes.append(.mySpotList(MySpotListFeature.State(viewState: .mapSearch, mbrLocation: mbrCoord, isSearch: isSearch, searchText: searchText)))
            
        case .tappedMarker:
            print("")
            
        case .bottomSheetDismiss:
            print("")
            
        case let .tappedSpotAddButton(coord):
            state.routes.append(.addSpotMap(AddSpotMapFeature.State(viewState: .searchMap, spotDetailEntity: SpotDetailEntity(), datas: [], spotCoord: coord)))
            
        case .tappedBackButton:
            _ = state.routes.popLast()
            
        case .tappedSearch:
            _ = state.routes.popLast()
            
        case let .tappedSpotDetail(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .mapSearch, spotId: spotId)))
        }
        
        return .none
    }
    
    private func addSpotMapAction(state: inout State, action: AddSpotMapFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedBackButton(viewState):
            _ = state.routes.popLast()
            
        case let .tappedAddConfirmButton(spotCoord, spotAddress, viewState, spotDetail, imageData):
            if viewState == .map || viewState == .searchMap {
                state.routes.append(.spotEditorView(SpotEditorFeature.State(viewState: .add, spotDetail: spotDetail, spotLocation: spotCoord, spotAddress: spotAddress, imageDatas: imageData, beforeViewState: .map)))
            } else {
                _ = state.routes.popLast()
                
                if let id = state.screenIds[.spotEditorView] {
                    return .run { send in
                        await send(.router(.element(id: id, action: .spotEditorView(.parentsAction(.changeAddress(spotCoord, spotAddress))))))
                    }
                }
            }
            
        case .onAppear:
            changeIsHidden(true, &state)
        }
        
        return .none
    }
    
    private func successAction(state: inout State, action: SuccessFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedConfirmButton:
//            state.$isHidden.withLock { $0 = false }
            state.routes.removeAll()
            
            return .send(.root(.parentsAction(.successAddSpot)))
        }
    }
    
    private func spotDetailAction(state: inout State, action: SpotDetailFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedNavBackButton(_, viewState):
            _ = state.routes.popLast()
            
            if viewState == .mapSearch {
                if let id = state.screenIds[.searchMap] {
                    return .send(.router(.element(id: id, action: .searchMap(.parentsAction(.detailBack)))))
                }
            } else if viewState == .map {
                return .send(.root(.parentsAction(.detailBack)))
            }
            
        case let .delete(viewState):
            state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
            state.popupIsPresent = true
            
            _ = state.routes.popLast()
            
            if viewState == .map {
                return .run { send in
                    await send(.root(.parentsAction(.deleteSpot)))
                }
            } else if viewState == .mapSearch {
                if let id = state.screenIds[.searchMap] {
                    return .run { send in
                        await send(.router(.element(id: id, action: .searchMap(.parentsAction(.deleteSpot)))))
                    }
                }
            } else {
                if let id = state.screenIds[.mySpotList] {
                    return .send(.router(.element(id: id, action: .mySpotList(.parentsAction(.delete)))))
                }
            }
            
        case let .editSpotDetail(spotDetail, viewState):
            if viewState == .map {
                state.routes.append(
                    .spotEditorView(
                        SpotEditorFeature.State(
                            viewState: .edit,
                            spotDetail: spotDetail,
                            spotLocation: Coordinate(latitude: 0, longitude: 0),
                            spotAddress: spotDetail.spotAddress,
                            imageDatas: [],
                            beforeViewState: .map
                        )
                    )
                )
            } else if viewState == .mapSearch {
                state.routes.append(
                    .spotEditorView(
                        SpotEditorFeature.State(
                            viewState: .edit,
                            spotDetail: spotDetail,
                            spotLocation: Coordinate(latitude: 0, longitude: 0),
                            spotAddress: spotDetail.spotAddress,
                            imageDatas: [],
                            beforeViewState: .searchMap
                        )
                    )
                )
            } else {
                state.routes.append(
                    .spotEditorView(
                        SpotEditorFeature.State(
                            viewState: .edit,
                            spotDetail: spotDetail,
                            spotLocation: Coordinate(latitude: 0, longitude: 0),
                            spotAddress: spotDetail.spotAddress,
                            imageDatas: [],
                            beforeViewState: .other
                        )
                    )
                )
            }
            
        case let .report(type, id):
            if type == "Post" {
                state.routes.append(.report(ReportFeature.State(viewState: .post, id: id)))
            } else {
                state.routes.append(.report(ReportFeature.State(viewState: .user, id: id)))
            }
            
        case let .reviewReport(id):
            state.routes.append(.report(ReportFeature.State(viewState: .review, id: id)))
            
        case let .deleteSpot(msg, viewState):
            _ = state.routes.popLast()
            
            if viewState == .map {
                return .send(.root(.parentsAction(.noSpotData(msg))))
            } else if viewState == .mapSearch {
                if let id = state.screenIds[.searchMap] {
                    return .send(.router(.element(id: id, action: .searchMap(.parentsAction(.noDataSpot(msg))))))
                }
            } else if viewState == .other {
                state.errorMSG = msg
                state.popupIsPresent = true
                
                if let id = state.screenIds[.mySpotList] {
                    return .send(.router(.element(id: id, action: .mySpotList(.parentsAction(.delete)))))
                }
            }
            
        case .onAppear:
            print("a")
            
        case let .changeArchive(spotId, isArchive, viewState):
            if let searchMapId = state.screenIds[.searchMap] {
                return .merge([
                    .send(.root(.parentsAction(.changeArchive(spotId, isArchive)))),
                    .send(.router(.element(id: searchMapId, action: .searchMap(.parentsAction(.changeArchive(spotId, isArchive))))))
                ])
            }
            
            return .send(.root(.parentsAction(.changeArchive(spotId, isArchive))))
            
        case .fetchData(_, _):
            print("a")
        }
        
        return .none
    }
    
    private func reportAction(state: inout State, action: ReportFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case .tappedConfirmButton:
            _ = state.routes.popLast()
            state.alertIsPresent = true
            state.$isHidden.withLock { $0 = false }
            
            return .run { send in
                await send(.root(.parentsAction(.deleteSpot)))
            }
            
        case .tappedBackButton:
            _ = state.routes.popLast()
        }
        
        return .none
    }
}

extension MapCoordinator.State {
    enum ScreenType {
        case mySpotList
        case spotEditorView
        case search
        case searchMap
        case addSpotMap
        case successView
        case spotDetail
        case report
    }

    var mySpotListId: StackElementID? {
        get { screenIds[.mySpotList] }
        set { screenIds[.mySpotList] = newValue }
    }

    var spotEditorViewId: StackElementID? {
        get { screenIds[.spotEditorView] }
        set { screenIds[.spotEditorView] = newValue }
    }

    var searchId: StackElementID? {
        get { screenIds[.search] }
        set { screenIds[.search] = newValue }
    }

    var searchMapId: StackElementID? {
        get { screenIds[.searchMap] }
        set { screenIds[.searchMap] = newValue }
    }

    var addSpotMapId: StackElementID? {
        get { screenIds[.addSpotMap] }
        set { screenIds[.addSpotMap] = newValue }
    }

    var successViewId: StackElementID? {
        get { screenIds[.successView] }
        set { screenIds[.successView] = newValue }
    }

    var spotDetailId: StackElementID? {
        get { screenIds[.spotDetail] }
        set { screenIds[.spotDetail] = newValue }
    }

    var reportId: StackElementID? {
        get { screenIds[.report] }
        set { screenIds[.report] = newValue }
    }
}

extension MapCoordinator {
    private func changeIsHidden(_ isHidden: Bool, _ state: inout State) {
        state.$isHidden.withLock { $0 = isHidden }
    }
}
