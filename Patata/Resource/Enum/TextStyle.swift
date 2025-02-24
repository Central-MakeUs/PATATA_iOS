//
//  TextStyle.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI

enum TextStyle {
    case headlineL
    case headlineM
    case headlineXS
    case headlineS
    case subtitleL
    case subtitleM
    case subtitleS
    case subtitleXS
    case subtitleSM
    case bodyM
    case bodyS
    case bodySM
    case captionM
    case captionS
    
    var font: Font {
        switch self {
        case .headlineL:
            return .pretendard(.bold, size: 36)
        case .headlineM:
            return .pretendard(.semibold, size: 30)
        case .headlineS:
            return .pretendard(.semibold, size: 24)
        case .subtitleL:
            return .pretendard(.semibold, size: 18)
        case .subtitleM:
            return .pretendard(.semibold, size: 16)
        case .subtitleS:
            return .pretendard(.semibold, size: 14)
        case .subtitleXS:
            return .pretendard(.semibold, size: 12)
        case .subtitleSM:
            return .pretendard(.semibold, size: 15)
        case .bodyM:
            return .pretendard(.regular, size: 16)
        case .bodyS:
            return .pretendard(.regular, size: 14)
        case .bodySM:
            return .pretendard(.medium, size: 14)
        case .captionM:
            return .pretendard(.regular, size: 12)
        case .captionS:
            return .pretendard(.semibold, size: 10)
        case .headlineXS:
            return .pretendard(.semibold, size: 20)
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .headlineL:
            return 48
        case .headlineM:
            return 40
        case .headlineS:
            return 32
        case .subtitleL:
            return 26
        case .subtitleM:
            return 24
        case .subtitleS:
            return 20
        case .subtitleXS:
            return 18
        case .subtitleSM:
            return 22
        case .bodyM:
            return 24
        case .bodyS:
            return 20
        case .bodySM:
            return 20
        case .captionM:
            return 18
        case .captionS:
            return 12
        case .headlineXS:
            return 26
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .headlineL:
            return 36
        case .headlineM:
            return 30
        case .headlineS:
            return 24
        case .subtitleL:
            return 18
        case .subtitleM:
            return 16
        case .subtitleS:
            return 14
        case .subtitleXS:
            return 12
        case .subtitleSM:
            return 15
        case .bodyM:
            return 16
        case .bodyS:
            return 14
        case .captionM:
            return 12
        case .captionS:
            return 10
        case .bodySM:
            return 14
        case .headlineXS:
            return 20
        }
    }
    
    var uiFont: UIFont {
        switch self {
        case .headlineL:
            return UIFont(name: "Pretendard-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
        case .headlineM:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .headlineS:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .headlineXS:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .subtitleL:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .subtitleM:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .subtitleS:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .subtitleXS:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .subtitleSM:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        case .bodyM:
            return UIFont(name: "Pretendard-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
        case .bodyS:
            return UIFont(name: "Pretendard-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
        case .bodySM:
            return UIFont(name: "Pretendard-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
        case .captionM:
            return UIFont(name: "Pretendard-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
        case .captionS:
            return UIFont(name: "Pretendard-SemiBold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        }
    }
}
