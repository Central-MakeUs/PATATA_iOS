//
//  MapCoordPath.swift
//  Patata
//
//  Created by 김진수 on 8/2/25.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum MapCoordPath {
    case mySpotList(MySpotListFeature)
    case spotEditorView(SpotEditorFeature)
    case search(SearchFeature)
    case searchMap(SearchMapFeature)
    case addSpotMap(AddSpotMapFeature)
    case successView(SuccessFeature)
    case spotDetail(SpotDetailFeature)
    case report(ReportFeature)
}
