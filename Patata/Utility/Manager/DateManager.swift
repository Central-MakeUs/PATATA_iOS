//
//  DateManager.swift
//  Patata
//
//  Created by 김진수 on 2/21/25.
//

import Foundation

final class DateManager {
    
    private init() {}
    
    static let shared = DateManager()
    
    private let isoDateFormatter = ISO8601DateFormatter()
    private let dateFormatter = DateFormatter()
    private let locale = Locale(identifier: "ko_KR")
    
    // ISO 8601 형식을 처리하는 함수
    func toDate(_ dateString: String) -> Date? {
        // isoDateFormatter의 formatOptions 설정을 조정하여 타임존 정보가 없는 경우도 처리
        isoDateFormatter.formatOptions = [.withFullDate, .withFullTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        // 타임존 정보가 없으면 "Z"를 추가하는 방법
        var formattedDateString = dateString
        if !dateString.contains("T") {
            return nil
        }
        // 끝에 'Z'를 붙여서 타임존 정보를 추가
        if !dateString.contains("Z") {
            formattedDateString += "Z"
        }
        
        // isoDateFormatter로 변환
        if let isoDate = isoDateFormatter.date(from: formattedDateString) {
            return isoDate
        }
        
        // 만약 ISO 형식으로 변환되지 않으면 다른 형식을 시도
        dateFormatter.dateFormat = "yy.MM.dd HH:mm"
        dateFormatter.locale = locale
        
        if let fallbackResult = dateFormatter.date(from: dateString) {
            return fallbackResult
        }
        
#if DEBUG
        print("fail")
#endif
        return nil
    }
    
    // Date를 String으로 변환하는 함수
    func toString(date: Date) -> String {
        dateFormatter.dateFormat = "yy.MM.dd HH:mm"
        dateFormatter.locale = locale
        return dateFormatter.string(from: date)
    }
    
    // String을 Date로 변환 후 다시 String으로 변환하는 함수
    func toDateString(_ dateString: String) -> String {
        guard let fallbackResult = toDate(dateString) else {
            return ""
        }
        return toString(date: fallbackResult)
    }
}
