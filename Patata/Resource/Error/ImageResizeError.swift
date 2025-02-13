//
//  ImageResizeError.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

enum ImageResizeError: Error {
    case totalSizeExceeded
    case invalidImage
    
    var localizedDescription: String {
        switch self {
        case .totalSizeExceeded:
            return "전체 이미지 크기가 10MB를 초과합니다."
        case .invalidImage:
            return "이미지 처리 중 오류가 발생했습니다."
        }
    }
}
