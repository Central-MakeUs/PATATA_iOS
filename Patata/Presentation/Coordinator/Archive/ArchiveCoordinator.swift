//
//  ArchiveCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ArchiveCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        @Shared var isHidden: Bool
        
        var routes: StackState<ArchiveCoorPath.State> = .init()
        var root: ArchiveFeature.State = .init()
        
        var screenIds: [ScreenType: StackElementID] = [:]
        var popupIsPresent: Bool = false
        var alertIsPresent: Bool = false
        var errorMSG: String = ""
        var spotArchive: Bool = false
        var changeArchive: Bool = false
        
        init(isHidden: @autoclosure () -> Bool = false) {
            self._isHidden = Shared(wrappedValue: isHidden(), .inMemory("isHidden"))
        }
    }
    
    enum Action {
        case router(StackActionOf<ArchiveCoorPath>)
        case root(ArchiveFeature.Action)
        
        case viewEvent(ViewEventType)
        case viewCycle(ViewCycle)
        
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
            ArchiveFeature()
        }
        
        core()
            .forEach(\.routes, action: \.router)
    }
}

extension ArchiveCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .root(.delegate(action)):
                return rootAction(state: &state, action: action)
                
            case let .router(.element(_, action)):
                return routerAction(state: &state, action: action)
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case .viewEvent(.dismissAlert):
                state.alertIsPresent = false
                
            case .viewCycle(.disAppear):
                if state.routes.isEmpty {
                    changeIsHidden(false, &state)
                } else {
                    changeIsHidden(true, &state)
                }
                
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
    
    private func rootAction(state: inout ArchiveCoordinator.State, action: ArchiveFeature.Action.Delegate) -> Effect<Action> {
        switch action {
        case let .tappedSpot(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
            state.screenIds[.spotDetail] = state.routes.ids.last
            
        case .tappedConfirmButton:
            changeIsHidden(true, &state)
            state.routes.append(.category(SpotCategoryFeature.State(initialIndex: 0)))
            state.screenIds[.category] = state.routes.ids.last
        }
        
        return .none
    }
    
    private func routerAction(state: inout ArchiveCoordinator.State, action: ArchiveCoorPath.Action) -> Effect<Action> {
        switch action {
        case let .spotDetail(.delegate(action)):
            return spotDetailAction(state: &state, action: action)
            
        case let .spotedit(.delegate(action)):
            return spotEditAction(state: &state, action: action)
            
        case let .addSpotMap(.delegate(action)):
            return addSpotAction(state: &state, action: action)
            
        case let .report(.delegate(action)):
            return reportAction(state: &state, action: action)
            
        case let .category(.delegate(action)):
            return categoryAction(state: &state, action: action)
            
        default:
            break
        }
        
        return .none
    }
    
    private func spotDetailAction(
        state: inout ArchiveCoordinator.State,
        action: SpotDetailFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .tappedNavBackButton(_, _):
            _ = state.routes.popLast()
            
        case .delete(_):
            _ = state.routes.popLast()
            state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
            state.popupIsPresent = true
            
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
            } else {
                state.routes.append(.report(ReportFeature.State(viewState: .user, id: id)))
            }
            state.screenIds[.report] = state.routes.ids.last
            
        case let .reviewReport(id):
            state.routes.append(.report(ReportFeature.State(viewState: .review, id: id)))
            state.screenIds[.report] = state.routes.ids.last
            
        case let .deleteSpot(msg, _):
            _ = state.routes.popLast()
            state.errorMSG = msg
            state.popupIsPresent = true
            
        case let .changeArchive(_, isArchive, _):
            state.changeArchive = isArchive
            // 여기서 archive상태를 기억하고 있다가 처음 상태랑 다르면 그때 반영
            // 여기서 바로 반영시키지말고 pop될때쯤?
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        case let .fetchData(isArchive, viewState):
            if state.changeArchive != isArchive {
                print("a")
            }
        }
        
        return .none
    }
    
    private func addSpotAction(
        state: inout ArchiveCoordinator.State,
        action: AddSpotMapFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .tappedBackButton(_):
            _ = state.routes.popLast()
            
        case let .tappedAddConfirmButton(coord, spotAddresss, _, _, _):
            _ = state.routes.popLast()
            
            if let id = state.screenIds[.spotedit] {
                return .run { send in
                    await send(.router(.element(id: id, action: .spotedit(.parentsAction(.changeAddress(coord, spotAddresss))))))
                }
            }
            
        default:
            break
        }
        
        return .none
    }
    
    private func spotEditAction(
        state: inout ArchiveCoordinator.State,
        action: SpotEditorFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .tappedBackButton:
            _ = state.routes.popLast()
            
        case .tappedXButton:
            state.routes.removeAll()
            
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
            
        case .successSpotEdit(_):
            state.errorMSG = "게시물이 수정되었습니다."
            _ = state.routes.popLast()
            state.popupIsPresent = true
            
        default:
            break
        }
        
        return .none
    }
    
    private func reportAction(
        state: inout ArchiveCoordinator.State,
        action: ReportFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .tappedConfirmButton:
            state.routes.removeAll()
            state.alertIsPresent = true
            
        case .tappedBackButton:
            _ = state.routes.popLast()
        }
        
        return .none
    }
    
    private func categoryAction(
        state: inout ArchiveCoordinator.State,
        action: SpotCategoryFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .tappedNavBackButton:
            _ = state.routes.popLast()
            
        case let .tappedSpot(spotId):
            state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
            
        case .onAppear:
            changeIsHidden(true, &state)
            
        default:
            break
        }
        
        return .none
    }
}

extension ArchiveCoordinator.State {
    enum ScreenType {
        case archive
        case spotDetail
        case spotedit
        case addSpotMap
        case report
        case category
    }
    
    var archiveId: StackElementID? {
        get { screenIds[.archive] }
        set { screenIds[.archive] = newValue }
    }

    var spotDetailId: StackElementID? {
        get { screenIds[.spotDetail] }
        set { screenIds[.spotDetail] = newValue }
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

    var categoryId: StackElementID? {
        get { screenIds[.category] }
        set { screenIds[.category] = newValue }
    }
}

extension ArchiveCoordinator {
    private func changeIsHidden(_ isHidden: Bool, _ state: inout State) {
        state.$isHidden.withLock { $0 = isHidden }
    }
}
