//
//  AddressManager.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import Foundation
import CoreLocation
import Combine

actor AddressManager {
    private let geocoder = CLGeocoder()
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 0.5 // 초당 2회 제한
    
    func getAddress(for coordinate: CLLocationCoordinate2D) async throws -> String {
        // 이전 요청과의 시간 간격 체크
        if let lastTime = lastRequestTime,
           Date().timeIntervalSince(lastTime) < minimumRequestInterval {
            try await Task.sleep(for: .seconds(minimumRequestInterval))
        }
        
        lastRequestTime = Date()
        
        let location = CLLocation(latitude: coordinate.latitude,
                                longitude: coordinate.longitude)
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.last else {
            throw PAError.locationError(APIResponseErrorDTO(isSuccess: false, code: "LOCATION FAIL", message: "주소를 찾을 수 없습니다."))
        }
        
        return formatAddress(from: placemark)
    }
}

extension AddressManager {
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let admin = placemark.administrativeArea {
            components.append(admin)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        
        return components.joined(separator: " ")
    }
}
