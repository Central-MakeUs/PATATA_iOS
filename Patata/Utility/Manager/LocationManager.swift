//
//  LocationManager.swift
//  Patata
//
//  Created by 김진수 on 2/10/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
@preconcurrency import CoreLocation
@preconcurrency import Combine

final class LocationManager: NSObject, Sendable {
    private let locationUpdateSubject = PassthroughSubject<Coordinate, Never>()
    let locationManager = CLLocationManager()
    private let cancelStoreActor = AnyValueActor(Set<AnyCancellable>())
    
    private override init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        locationManager.delegate = self
        
//         백그라운드 위치 업데이트 설정
//        if Bundle.main.backgroundModes.contains("location") {
//            locationManager.allowsBackgroundLocationUpdates = true
//            locationManager.pausesLocationUpdatesAutomatically = true
//        }
    }
    
    func checkLocationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            PermissionManager.shared.checkLocationPermission { hasPermission in
                continuation.resume(returning: hasPermission)
            }
        }
    }
    
    func getLocationUpdates() -> AsyncStream<Coordinate> {
        return AsyncStream { continuation in
            Task {
                let subscription = locationUpdateSubject
                    .sink { coordinate in
                        continuation.yield(coordinate)
                    }
                
                await cancelStoreActor.withValue { value in
                    value.insert(subscription)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.cancelStoreActor.resetValue()
                    continuation.finish()
                }
            }
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let coordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        locationUpdateSubject.send(coordinate)
    }
}


extension LocationManager {
    static let shared = LocationManager()
}

extension LocationManager: DependencyKey {
    static let liveValue: LocationManager = LocationManager.shared
}

extension DependencyValues {
    var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}
