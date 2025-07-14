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
    case updateVersion
    
    var title : String {
        switch self {
        case .imagePermission:
            "사진 권한 필요"
        case .locationPermission:
            "위치 권한 필요"
        case .updateVersion:
            "업데이트 알림"
        }
    }
    
    var actionTitle: String {
        switch self {
        case .imagePermission, .locationPermission:
            return "설정으로 이동"
        case .updateVersion:
            return "업데이트"
        }
    }
    
    var message: String {
        switch self {
        case .imagePermission:
            return "사진 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요."
            
        case .locationPermission:
            return "위치 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요."
            
        case .updateVersion:
            return "더 나은 서비스를 위해 파타타가 업데이트 되었습니다.\n원활한 서비스를 위해 업데이트를 해주세요."
        }
    }
    
    var cancelTitle: String {
        switch self {
        case .imagePermission, .locationPermission:
            return "취소"
        case .updateVersion:
            return "다음에"
        }
    }
}
