//
//  MyPageCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case myPage(MyPageFeature)
    case setting(SettingFeature)
    case deleteID(DeleteIDFeature)
    case profileEdit(ProfileEditFeature)
    case success(SuccessFeature)
    case spotDetail(SpotDetailFeature)
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
}

@Reducer
struct MyPageCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.myPage(MyPageFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<MyPageScreen.State>>
        
        var isHideTabBar: Bool = false
        var popupIsPresent: Bool = false
        var errorMSG: String = ""
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MyPageScreen>)
        
        case viewEvent(ViewEventType)
        case delegate(Delegate)
        
        case bindingPopupIsPresent(Bool)
        
        enum Delegate {
            case tappedLogout
            case successRevoke
        }
    }
    
    enum ViewEventType {
        case dismissPopup
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .router(.routeAction(id: .myPage, action: .myPage(.delegate(.tappedSetting)))):
                state.isHideTabBar = true
                state.routes.push(.setting(SettingFeature.State()))
                
            case .router(.routeAction(id: .myPage, action: .myPage(.delegate(.tappedProfileEdit)))):
                state.isHideTabBar = true
                state.routes.push(.profileEdit(ProfileEditFeature.State(viewState: .edit, nickname: UserDefaultsManager.nickname, initialNickname: UserDefaultsManager.nickname)))
                
            case let .router(.routeAction(id: .myPage, action: .myPage(.delegate(.tappedSpot(spotId))))):
                state.isHideTabBar = true
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton(_))))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete)))):
                state.routes.pop()
                state.isHideTabBar = false
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.editSpotDetail(spotAddress))))):
                state.routes.push(.spotedit(SpotEditorFeature.State(viewState: .edit, spotLocation: Coordinate(latitude: 0, longitude: 0), spotAddress: spotAddress)))
                
            case .router(.routeAction(id: .setting, action: .setting(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: .setting, action: .setting(.delegate(.tappedLogout)))):
                return .send(.delegate(.tappedLogout))
                
            case .router(.routeAction(id: .setting, action: .setting(.delegate(.tappedDeleteID)))):
                state.routes.push(.deleteID(DeleteIDFeature.State()))
                
            case .router(.routeAction(id: .deleteID, action: .deleteID(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .deleteID, action: .deleteID(.delegate(.succesRevoke)))):
                return .send(.delegate(.successRevoke))
                
            case let .router(.routeAction(id: .profileEdit, action: .profileEdit(.delegate(.tappedBackButton(viewState))))):
                if viewState == .edit {
                    state.isHideTabBar = false
                    state.routes.pop()
                }
                
            case .router(.routeAction(id: .profileEdit, action: .profileEdit(.delegate(.successChangeNickname)))):
                state.routes.push(.success(SuccessFeature.State()))
                
            case .router(.routeAction(id: .success, action: .success(.delegate(.tappedConfirmButton)))):
                state.isHideTabBar = false
                state.routes.popToRoot()
                return .run { [routes = state.routes] send in
                        if let archiveIndex = routes.index(id: .myPage) {
                            await send(.router(.routeAction(
                                id: routes[archiveIndex].id,
                                action: .myPage(.delegate(.changeNickName))
                            )))
                        }
                    }
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddress, _))))):
                state.routes.pop()
                
                return .run { send in
                    await send(.router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.changeAddress(coord, spotAddress))))))
                }
                
            case .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedXButton)))):
                state.routes.popToRoot()
                state.isHideTabBar = false
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.successSpotAdd)))):
                state.routes.pop()
                
            case let .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedLocation(coord, _))))):
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotCoord: coord)))
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case let .bindingPopupIsPresent(popup):
                state.popupIsPresent = popup
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
