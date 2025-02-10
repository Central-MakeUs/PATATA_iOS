//
//  AlertMessage.swift
//  Patata
//
//  Created by 김진수 on 2/10/25.
//

import Foundation

enum AlertMessage: Equatable {
    
    case imagePermission
    case locationPermission
    
    var title : String {
        switch self {
        case .imagePermission:
            "사진 권한 필요"
        case .locationPermission:
            "위치 권한 필요"
        }
    }
    
    var actionTitle: String {
        switch self {
        case .imagePermission, .locationPermission:
            return "설정으로 이동"
        }
    }
    
    var message: String {
        switch self {
        case .imagePermission:
            return "사진 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요."
            
        case .locationPermission:
            return "위치 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요."
        }
    }
    
    var cancelTitle: String {
        switch self {
        case .imagePermission, .locationPermission:
            return "취소"
        }
    }
}
