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

class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = PermissionManager()
    private let locationManager = CLLocationManager()
    
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var photoAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        locationManager.delegate = self
        checkInitialPermissions()
    }
    
    // 위치 권한 체크 및 처리
    func checkLocationPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = locationManager.authorizationStatus
        
        switch currentStatus {
        case .notDetermined:
            // 권한 요청이 처음인 경우
            locationManager.requestWhenInUseAuthorization()
            // delegate에서 상태 변경을 감지하여 completion 호출
            completion(false)
            
        case .restricted, .denied:
            // 권한이 거부된 경우 설정으로 이동
            completion(false)
            
        case .authorizedWhenInUse, .authorizedAlways:
            // 이미 권한이 있는 경우
            completion(true)
            
        @unknown default:
            completion(false)
        }
    }
    
    // 사진 권한 체크 및 처리
    func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        
        switch currentStatus {
        case .notDetermined:
            // 권한 요청이 처음인 경우
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
            
        case .restricted, .denied:
            // 권한이 거부된 경우 설정으로 이동
            completion(false)
            
        case .authorized, .limited:
            // 이미 권한이 있는 경우
            completion(true)
            
        @unknown default:
            completion(false)
        }
    }
}

extension PermissionManager {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationAuthorizationStatus = manager.authorizationStatus
        }
    }
    
    private func checkInitialPermissions() {
        locationAuthorizationStatus = locationManager.authorizationStatus
    }
}
