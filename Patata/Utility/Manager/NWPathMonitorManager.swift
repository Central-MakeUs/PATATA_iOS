//
//  NWPathMonitorManager.swift
//  Patata
//
//  Created by 김진수 on 2/28/25.
//

import Foundation
import Network
import Combine
import ComposableArchitecture

final class NWPathMonitorManager: @unchecked Sendable {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkManager")
    private let connectionTypeSubject = PassthroughSubject<ConnectionType, Never>()
    private let currentConnectionTrigger = CurrentValueSubject<Bool, Never> (true)
    
    static let shared = NWPathMonitorManager()
    private init () {}
    
    enum ConnectionType {
        case cellular
        case ethernet
        case wifi
        case unknown
    }
    
    func start() {
        startMonitoring()
        #if DEBUG
        print(#function)
        #endif
    }
    
    func getToConnectionType() -> AnyPublisher<ConnectionType, Never> {
        return connectionTypeSubject.eraseToAnyPublisher()
    }
    
    func getToConnectionTrigger() -> AsyncStream<Bool> {
        return AsyncStream { [weak self] continuation in
            guard let weakSelf = self else { return }
            
            weakSelf.monitor.pathUpdateHandler = { path in
                Task {
                    let trigger = weakSelf.networkConnectStatus(path: path)
                    #if DEBUG
                    print(trigger)
                    #endif
                    continuation.yield(trigger)
                }
            }
        }
    }
    
    func stop() {
        monitor.cancel()
        #if DEBUG
        print(#function)
        #endif
    }
    
}

extension NWPathMonitorManager {
    
    private func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    private func updateHandler(path: NWPath) {
        getConnectionType(path: path)
        #if DEBUG
        print(#function)
        print(path.status)
        #endif
    }

    
    private func getConnectionType(path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionTypeSubject.send(.wifi)
        } else if path.usesInterfaceType(.cellular) {
            connectionTypeSubject.send(.cellular)
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionTypeSubject.send(.ethernet)
        } else {
            connectionTypeSubject.send(.unknown)
        }
    }
    
    private func networkConnectStatus(path: NWPath) -> Bool {
        return path.status == .satisfied
    }
}


extension NWPathMonitorManager: DependencyKey {
    static let liveValue: NWPathMonitorManager = NWPathMonitorManager.shared
}

extension DependencyValues {
    var nwPathMonitorManager: NWPathMonitorManager {
        get { self[NWPathMonitorManager.self] }
        set { self[NWPathMonitorManager.self] = newValue }
    }
}

