//
//  SemanticColor.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI

enum SemanticColor {
    // Text colors
    static let textDefault = UIColor(hexCode: "#1C1C1C")   // 기본 텍스트, Heading에 사용
    static let textSub = UIColor(hexCode: "#2E3035")       // 두번째 텍스트, 본문에 사용
    static let textInfo = UIColor(hexCode: "#727883")      // 부가정보 텍스트, 유의사항 등
    static let textDisabled = UIColor(hexCode: "#B0B5BF")  // 비활성화된 텍스트
    
    // Background & Border colors
    static let border = UIColor(hexCode: "#CACED8")        // 영역을 구분할 때 사용하는 구분선
    static let bgGrouped = UIColor(hexCode: "#F6F7F8")     // 페이지 내에서 특정 컨텐츠 영역 구분시 사용
    static let bgOverlay = UIColor(hexCode: "#1C1C1C", alpha: 0.3)  // 팝업이 뜰 때 뒷면에 오버레이
}
