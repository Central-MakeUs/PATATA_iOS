//
//  HomeCoordPath.swift
//  Patata
//
//  Created by 김진수 on 7/30/25.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum HomeCoordPath {
    case home(PatataMainFeature)
    case search(SearchFeature)
    case category(SpotCategoryFeature)
    case spotDetail(SpotDetailFeature)
    case mySpotList(MySpotListFeature)
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
    case report(ReportFeature)
}
