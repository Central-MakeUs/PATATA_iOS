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
    let locationManager = CLLocationManager()
    
    private let locationUpdateSubject = PassthroughSubject<Coordinate, Never>()
    private let cancelStoreActor = AnyValueActor(Set<AnyCancellable>())
    private let defaultLocation = CLLocationCoordinate2D(latitude: 37.5666791, longitude: 126.9782914)
    private let dataSourceActor = DataSourceActor()
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
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
                
                if let coordinate = self.locationManager.location?.coordinate {
                    
                    let coord = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    Task {
                        do {
                            try await self.createCoord(coord: coord)
                        } catch {
                            // 에러 발생 시 처리
                            print("Failed to create coordinate:", error)
                            // 실패 시 기본 좌표 사용
                            let defaultCoordinate = Coordinate(
                                latitude: self.defaultLocation.latitude,
                                longitude: self.defaultLocation.longitude
                            )
                            
                            self.locationUpdateSubject.send(defaultCoordinate)
                        }
                    }
                    
                } else {
                    let defaultCoordinate = Coordinate(
                        latitude: self.defaultLocation.latitude,
                        longitude: self.defaultLocation.longitude
                    )

                    Task {
                        do {
                            try await self.createCoord(coord: defaultCoordinate)
                        } catch {
                            // 에러 발생 시 처리
                            print("Failed to create coordinate:", error)
                            // 실패 시 기본 좌표 사용
                            let defaultCoordinate = Coordinate(
                                latitude: self.defaultLocation.latitude,
                                longitude: self.defaultLocation.longitude
                            )
                            
                            self.locationUpdateSubject.send(defaultCoordinate)
                        }
                    }
                    
                }
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            print("Authorization changed:", manager.authorizationStatus.rawValue)
        }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations", locations)
        guard let location = locations.last else { return }
        
        print("didUpdateLocations", location)
        
        let coordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        locationUpdateSubject.send(coordinate)
    }
}

extension LocationManager {
    private func createCoord(coord: Coordinate) async throws {
        try await self.dataSourceActor.coordCreate(coord: coord)
        self.locationUpdateSubject.send(coord)
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
