//
//  MyPageCoordPath.swift
//  Patata
//
//  Created by 김진수 on 8/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum MyPageCoordPath {
    case setting(SettingFeature)
    case deleteID(DeleteIDFeature)
    case profileEdit(ProfileEditFeature)
    case success(SuccessFeature)
    case spotDetail(SpotDetailFeature)
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
    case openSource(OpenSourceFeature)
}
