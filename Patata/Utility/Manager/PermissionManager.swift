//
//  PermissionManager.swift
//  Patata
//
//  Created by 김진수 on 2/10/25.
//

import Foundation
import CoreLocation
import Photos
import UIKit

final class PermissionManager: NSObject {
    static let shared = PermissionManager()
    private let locationManager: CLLocationManager
    
    private override init() {
        self.locationManager = LocationManager.shared.locationManager
        super.init()
    }
    
    func checkLocationPermission(completion: @escaping (Bool) -> Void) {
                
        let currentStatus = locationManager.authorizationStatus
        
        switch currentStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            completion(true)
            
        case .restricted, .denied:
            completion(false)
            
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
            
        @unknown default:
            completion(false)
        }
    }
    
    func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        
        switch currentStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
            
        case .restricted, .denied:
            completion(false)
            
        case .authorized, .limited:
            completion(true)
            
        @unknown default:
            completion(false)
        }
    }
}
