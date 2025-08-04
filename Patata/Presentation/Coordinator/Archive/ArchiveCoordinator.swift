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
        
        init(isHidden: @autoclosure () -> Bool = false) {
            self._isHidden = Shared(wrappedValue: isHidden(), .inMemory("isHidden"))
        }
    }
    
    enum Action {
        case router(StackActionOf<ArchiveCoorPath>)
        case root(ArchiveFeature.Action)
        
        case viewEvent(ViewEventType)
        
        case bindingPopupIsPresent(Bool)
        case bindingAlertIsPrenset(Bool)
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
    }
}

extension ArchiveCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .root(.delegate(.tappedSpot(spotId))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                state.screenIds[.spotDetail] = state.routes.ids.last
                
            case .root(.delegate(.tappedConfirmButton)):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.category(SpotCategoryFeature.State(initialIndex: 0)))
                state.screenIds[.category] = state.routes.ids.last
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.report(type, id))))):
                if type == "Post" {
                    state.routes.append(.report(ReportFeature.State(viewState: .post, id: id)))
                } else {
                    state.routes.append(.report(ReportFeature.State(viewState: .user, id: id)))
                }
                state.screenIds[.report] = state.routes.ids.last
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.reviewReport(id: id))))):
                state.routes.append(.report(ReportFeature.State(viewState: .review, id: id)))
                state.screenIds[.report] = state.routes.ids.last
                
            case .router(.element(id: _, action: .spotDetail(.delegate(.tappedNavBackButton(_, _))))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .spotDetail(.delegate(.delete(_))))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.deleteSpot(msg, _))))):
                _ = state.routes.popLast()
                state.errorMSG = msg
                state.popupIsPresent = true
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.editSpotDetail(spotDetail, _))))):
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
                
            case let .router(.element(id: _, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddresss, _, _, _))))):
                _ = state.routes.popLast()
                
                if let id = state.screenIds[.spotedit] {
                    return .run { send in
                        await send(.router(.element(id: id, action: .spotedit(.parentsAction(.changeAddress(coord, spotAddresss))))))
                    }
                }
                
            case .router(.element(id: _, action: .addSpotMap(.delegate(.tappedBackButton(_))))):
                _ = state.routes.popLast()

            case .router(.element(id: _, action: .spotedit(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .spotedit(.delegate(.tappedXButton)))):
                state.routes.removeAll()
                state.$isHidden.withLock { $0 = false }
                
            case .router(.element(id: _, action: .spotedit(.delegate(.successSpotEdit)))):
                state.errorMSG = "게시물이 수정되었습니다."
                _ = state.routes.popLast()
                state.popupIsPresent = true
                
            case let .router(.element(id: _, action: .spotedit(.delegate(.tappedLocation(coord, _, spotDetail, _))))):
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
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case .viewEvent(.dismissAlert):
                state.alertIsPresent = false
                
            case .router(.element(id: _, action: .report(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .report(.delegate(.tappedConfirmButton)))):
                state.routes.removeAll()
                state.$isHidden.withLock { $0 = false }
                state.alertIsPresent = true
                
            case .router(.element(id: _, action: .category(.delegate(.tappedNavBackButton)))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()
                
            case let .router(.element(id: _, action: .category(.delegate(.tappedSpot(spotId))))):
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                
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
