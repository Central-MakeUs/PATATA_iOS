//
//  DistanceUnit.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

enum DistanceUnit {
    case meters
    case kilometers
    
    static private func detectDistanceUnit(_ distance: Double) -> (value: Double, unit: DistanceUnit) {
        if distance < 1.0 {  // 1km 미만은 미터로 표시
            return (distance * 1000, .meters)  // km를 m로 변환
        }
        
        // 1km 이상은 km로 표시
        return (distance, .kilometers)
    }
    
    static func formatDistance(_ distance: Double) -> String {
        let result = detectDistanceUnit(distance)
        if result.unit == .meters {
            return String(format: "%.0fm", result.value)  // 미터는 소수점 없이
        } else {
            return String(format: "%.1fkm", result.value) // km는 소수점 한자리
        }
    }
}
