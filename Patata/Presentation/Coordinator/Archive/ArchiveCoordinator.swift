//
//  ArchiveCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum ArchiveScreen {
    case archive(ArchiveFeature)
    case spotDetail(SpotDetailFeature)
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
    case report(ReportFeature)
}

@Reducer
struct ArchiveCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.archive(ArchiveFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<ArchiveScreen.State>>
        
        var isHideTabBar: Bool = false
        var popupIsPresent: Bool = false
        var alertIsPresent: Bool = false
        var errorMSG: String = ""
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ArchiveScreen>)
        
        case viewEvent(ViewEventType)
        case delegate(Delegate)
        
        case bindingPopupIsPresent(Bool)
        case bindingAlertIsPrenset(Bool)
        
        enum Delegate {
            case tappedConfirmButton
        }
    }
    
    enum ViewEventType {
        case dismissPopup
        case dismissAlert
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension ArchiveCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: .archive, action: .archive(.delegate(.tappedSpot(spotId))))):
                state.isHideTabBar = true
                state.routes.push(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                
            case .router(.routeAction(id: .archive, action: .archive(.delegate(.tappedConfirmButton)))):
                return .send(.delegate(.tappedConfirmButton))
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.report(type, id))))):
                if type == "Post" {
                    state.routes.push(.report(ReportFeature.State(viewState: .post, id: id)))
                } else {
                    state.routes.push(.report(ReportFeature.State(viewState: .user, id: id)))
                }
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton(_, _))))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete)))):
                state.isHideTabBar = false
                state.routes.pop()
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.editSpotDetail(spotDetail, _))))):
                state.routes.push(.spotedit(SpotEditorFeature.State(viewState: .edit, spotDetail: spotDetail, spotLocation: spotDetail.spotCoord, spotAddress: spotDetail.spotAddress, beforeViewState: .other)))
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddress, _))))):
                state.routes.pop()
                
                return .run { send in
                    await send(.router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.changeAddress(coord, spotAddress))))))
                }
                
            case .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedBackButton(_))))):
                state.routes.pop()
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedXButton)))):
                state.routes.popToRoot()
                state.isHideTabBar = false
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.successSpotEdit)))):
                state.errorMSG = "게시물이 수정되었습니다."
                state.routes.pop()
                state.popupIsPresent = true
                
            case let .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedLocation(coord, _))))):
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotCoord: coord)))
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case .viewEvent(.dismissAlert):
                state.alertIsPresent = false
                
            case .router(.routeAction(id: .report, action: .report(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .report, action: .report(.delegate(.tappedConfirmButton)))):
                state.routes.popToRoot()
                state.isHideTabBar = false
                state.alertIsPresent = true
                
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
