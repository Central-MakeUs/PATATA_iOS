//
//  TabCase.swift
//  Patata
//
//  Created by 김진수 on 1/17/25.
//

import Foundation

enum TabCase {
    case home
    case map
    case archive
    case myPage
}

struct TabAsset {
    let inactive: String
    let active: String
    let title: String
}

extension TabCase {
    static let order: [TabCase] = [.home, .map, .archive, .myPage]
    var asset: TabAsset {
        switch self {
        case .home:
            return .init(inactive: "HomeInActive", active: "HomeActive", title: "홈")
            
        case .map:
            return .init(inactive: "SpotInActive", active: "SpotActive", title: "내주변")
            
        case .archive:
            return .init(inactive: "ArchiveInActiveTap", active: "ArchiveActiveTap", title: "아카이브")
            
        case .myPage:
            return .init(inactive: "MyPageInActive", active: "MyPageActive", title: "My")
        }
    }
}
