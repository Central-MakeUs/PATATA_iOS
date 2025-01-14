//
//  ExColor.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI
 
extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}

extension Color {
   // Blue colors
   static let blue10 = Color(hex: "E6F7FF")
   static let blue20 = Color(hex: "B7E4FB")
   static let blue50 = Color(hex: "6FC9F6")
   static let blue100 = Color(hex: "20ACF2")
   
   // Navy colors
   static let navy20 = Color(hex: "405493")
   static let navy50 = Color(hex: "172A5D")
   static let navy100 = Color(hex: "020514")
   
   // Yellow colors
   static let yellow20 = Color(hex: "FDF2C4")
   static let yellow100 = Color(hex: "FFDD50")
   
   // Red colors
   static let red20 = Color(hex: "FBCCCB")
   static let red100 = Color(hex: "EF4743")
   
   // Gray colors
   static let gray10 = Color(hex: "F6F7F8")
   static let gray20 = Color(hex: "EBEFF3")
   static let gray30 = Color(hex: "D9DEE5")
   static let gray40 = Color(hex: "CACFD8")
   static let gray50 = Color(hex: "B6BDC7")
   static let gray60 = Color(hex: "A0A7B1")
   static let gray70 = Color(hex: "808791")
   static let gray80 = Color(hex: "555A63")
   static let gray90 = Color(hex: "2E3035")
   static let gray100 = Color(hex: "1C1C1C")
   
   // Semantic colors
   // Text colors
   static let textDefault = Color(hex: "1C1C1C")    // 기본 텍스트, Heading에 사용
   static let textSub = Color(hex: "2E3035")        // 두번째 텍스트, 본문에 사용
   static let textInfo = Color(hex: "727883")       // 부가정보 텍스트, 유의사항 등
   static let textDisabled = Color(hex: "B0B5BF")   // 비활성화된 텍스트
   
   // Background & Border colors
   static let border = Color(hex: "CACED8")         // 영역을 구분할 때 사용하는 구분선
   static let bgGrouped = Color(hex: "F6F7F8")      // 페이지 내에서 특정 컨텐츠 영역 구분시 사용
   static let bgOverlay = Color(hex: "1C1C1C").opacity(0.3)  // 팝업이 뜰 때 뒷면에 오버레이
}
