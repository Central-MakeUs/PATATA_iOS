//
//  DateManager.swift
//  Patata
//
//  Created by 김진수 on 2/21/25.
//

import Foundation

final class DateManager {
    static let shared = DateManager()
    
    private let isoFormatter: ISO8601DateFormatter
    private let outputFormatter: DateFormatter
    
    private init() {
        // ISO 날짜 포맷터 설정
        isoFormatter = ISO8601DateFormatter()
        
        // 출력용 포맷터 설정
        outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yy.MM.dd HH:mm"
        outputFormatter.timeZone = TimeZone.current
    }
    
    func formatToCustomDate(_ isoString: String) -> String {
        guard let date = isoFormatter.date(from: isoString) else {
            return ""  // 또는 에러 처리나 기본값 반환
        }
        return outputFormatter.string(from: date)
    }
    
    // 필요한 경우 다른 포맷으로도 변환할 수 있는 메서드 추가
    func formatWithCustomFormat(_ isoString: String, format: String) -> String {
        guard let date = isoFormatter.date(from: isoString) else {
            return ""
        }
        outputFormatter.dateFormat = format
        let result = outputFormatter.string(from: date)
        outputFormatter.dateFormat = "yy.MM.dd HH:mm"  // 기본 포맷으로 재설정
        return result
    }
}
