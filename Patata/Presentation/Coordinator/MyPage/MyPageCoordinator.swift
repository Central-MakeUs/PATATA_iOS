//
//  MyPageCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyPageCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        @Shared var isHidden: Bool
        
        var routes: StackState<MyPageCoordPath.State> = .init()
        var root: MyPageFeature.State = .init()
        var screenIds: [ScreenType: StackElementID] = [:]
        
        var popupIsPresent: Bool = false
        var errorMSG: String = ""
        
        init(isHidden: @autoclosure () -> Bool = false) {
            self._isHidden = Shared(wrappedValue: isHidden(), .inMemory("isHidden"))
        }
    }
    
    enum Action {
        case router(StackActionOf<MyPageCoordPath>)
        case root(MyPageFeature.Action)
        
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
        Scope(state: \.root, action: \.root) {
            MyPageFeature()
        }
        
        core()
    }
}

extension MyPageCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .root(.delegate(.tappedSetting)):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.setting(SettingFeature.State()))
                state.screenIds[.setting] = state.routes.ids.last
                
            case let .root(.delegate(.tappedProfileEdit(data))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.profileEdit(ProfileEditFeature.State(viewState: .edit, profileData: data)))
                state.screenIds[.profileEdit] = state.routes.ids.last
                
            case let .root(.delegate(.tappedAddSpotButton(coord))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.addSpotMap(AddSpotMapFeature.State(viewState: .map, spotDetailEntity: SpotDetailEntity(), datas: [], spotCoord: coord)))
                state.screenIds[.addSpotMap] = state.routes.ids.last
                
            case let .root(.delegate(.tappedSpot(spotId))):
                state.$isHidden.withLock { $0 = true }
                state.routes.append(.spotDetail(SpotDetailFeature.State(viewState: .other, spotId: spotId)))
                state.screenIds[.spotDetail] = state.routes.ids.last
                
            case .router(.element(id: _, action: .spotDetail(.delegate(.tappedNavBackButton(_, _))))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .spotDetail(.delegate(.delete(_))))):
                _ = state.routes.popLast()
                state.$isHidden.withLock { $0 = false }
                state.errorMSG = "게시물이 정상적으로 삭제되었습니다."
                state.popupIsPresent = true
                
            case let .router(.element(id: _, action: .spotDetail(.delegate(.editSpotDetail(spotDetail, _))))):
                state.routes.append(
                    .spotedit(
                        SpotEditorFeature
                            .State(
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
                
            case .router(.element(id: _, action: .setting(.delegate(.tappedBackButton)))):
                state.$isHidden.withLock { $0 = false }
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .setting(.delegate(.tappedLogout)))):
                return .send(.delegate(.tappedLogout))
                
            case .router(.element(id: _, action: .setting(.delegate(.tappedDeleteID)))):
                state.routes.append(.deleteID(DeleteIDFeature.State()))
                state.screenIds[.deleteID] = state.routes.ids.last
                
            case .router(.element(id: _, action: .deleteID(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .deleteID(.delegate(.succesRevoke)))):
                return .send(.delegate(.successRevoke))
                
            case let .router(.element(id: _, action: .profileEdit(.delegate(.tappedBackButton(viewState))))):
                if viewState == .edit {
                    state.$isHidden.withLock { $0 = false }
                    _ = state.routes.popLast()
                }

            case .router(.element(id: _, action: .profileEdit(.delegate(.successChangeNickname)))):
                state.$isHidden.withLock { $0 = false }
                state.routes.removeAll()
                
            case .router(.element(id: _, action: .success(.delegate(.tappedConfirmButton)))):
                state.$isHidden.withLock { $0 = false }
                state.routes.removeAll()
                
            case let .router(.element(id: _, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddress, viewState, spotDetail, datas: imageData))))):
                if viewState == .map {
                    state.routes.append(
                        .spotedit(
                            SpotEditorFeature.State(
                                viewState: .add,
                                spotDetail: spotDetail,
                                spotLocation: coord,
                                spotAddress: spotAddress,
                                imageDatas: imageData,
                                beforeViewState: .other
                            )
                        )
                    )
                    
                    state.screenIds[.spotedit] = state.routes.ids.last
                } else {
                    _ = state.routes.popLast()
                    
                    if let id = state.screenIds[.spotedit] {
                        return .run { send in
                            await send(.router(.element(id: id, action: .spotedit(.parentsAction(.changeAddress(coord, spotAddress))))))
                        }
                    }
                }
                
            case let .router(.element(id: _, action: .addSpotMap(.delegate(.tappedBackButton(viewState))))):
                if viewState == .map {
                    state.$isHidden.withLock { $0 = false }
                }
                
                _ = state.routes.popLast()
                
            case .router(.element(id: _, action: .spotedit(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()
                
                if let id = state.screenIds[.addSpotMap] {
                    return .send(.router(.element(id: id, action: .addSpotMap(.parentsAction(.tappedEditorBackButton)))))
                }
                
            case .router(.element(id: _, action: .spotedit(.delegate(.successSpotAdd)))):
                state.routes.append(.success(SuccessFeature.State(viewState: .spot)))
                
            case .router(.element(id: _, action: .spotedit(.delegate(.successSpotEdit(_))))):
                state.errorMSG = "게시물이 수정되었습니다."
                _ = state.routes.popLast()
                state.popupIsPresent = true
                
            case .router(.element(id: _, action: .spotedit(.delegate(.tappedXButton)))):
                state.routes.removeAll()
                state.$isHidden.withLock { $0 = false }
                
            case let .router(.element(id: _, action: .spotedit(.delegate(.tappedLocation(coord, viewState, spotDetail, imageData))))):
                if viewState == .add {
                    _ = state.routes.popLast()
                    
                    if let id = state.screenIds[.addSpotMap] {
                        return .send(.router(.element(id: id, action: .addSpotMap(.parentsAction(.popEditorView(spotDetail, imageData))))))
                    }
                } else {
                    state.routes.append(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotDetailEntity: spotDetail, datas: [], spotCoord: coord)))
                }
                
            case .router(.element(id: _, action: .setting(.delegate(.tappedOpenSource)))):
                state.routes.append(.openSource(OpenSourceFeature.State()))
                
            case .router(.element(id: _, action: .openSource(.delegate(.tappedBackButton)))):
                _ = state.routes.popLast()

            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case let .bindingPopupIsPresent(popup):
                state.popupIsPresent = popup
                
            default:
                break
            }
            
            return .none
        }
        .forEach(\.routes, action: \.router)
    }
}

extension MyPageCoordinator.State {
    enum ScreenType {
        case setting
        case deleteID
        case profileEdit
        case success
        case spotDetail
        case spotedit
        case addSpotMap
        case openSource
    }

    var settingId: StackElementID? {
        get { screenIds[.setting] }
        set { screenIds[.setting] = newValue }
    }

    var deleteIDId: StackElementID? {
        get { screenIds[.deleteID] }
        set { screenIds[.deleteID] = newValue }
    }

    var profileEditId: StackElementID? {
        get { screenIds[.profileEdit] }
        set { screenIds[.profileEdit] = newValue }
    }

    var successId: StackElementID? {
        get { screenIds[.success] }
        set { screenIds[.success] = newValue }
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

    var openSourceId: StackElementID? {
        get { screenIds[.openSource] }
        set { screenIds[.openSource] = newValue }
    }

}
