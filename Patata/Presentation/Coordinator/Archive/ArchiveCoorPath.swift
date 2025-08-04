//
//  ArchiveCoorPath.swift
//  Patata
//
//  Created by 김진수 on 8/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum ArchiveCoorPath {
    case spotDetail(SpotDetailFeature)
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
    case report(ReportFeature)
    case category(SpotCategoryFeature)
}
