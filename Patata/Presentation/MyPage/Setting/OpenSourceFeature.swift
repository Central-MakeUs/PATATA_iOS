//
//  OpenSourceFeature.swift
//  Patata
//
//  Created by 김진수 on 2/19/25.
//

import Foundation
import ComposableArchitecture

// 라이선스 정보를 담는 구조체
struct License: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let licenseType: String
    let licenseText: String
}

@Reducer
struct OpenSourceFeature {
    @ObservableState
    struct State: Equatable {
        var appVersion: String = ""
        var licenses: [License] = []
        var selectedLicense: License?
        var isLicenseDetailPresented: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case viewCycle(ViewCycle)
        case delegate(Delegate)
        
        case binding(Bool)
        
        enum Delegate {
            case tappedBackButton
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedBackButton
        case tappedLicense(License)
        case dismissLicenseDetail
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension OpenSourceFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                state.appVersion = appVersion
                state.licenses = createLicenseList()
                
            case let .viewEvent(.tappedLicense(license)):
                state.selectedLicense = license
                state.isLicenseDetailPresented = true
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case let .binding(bool):
                state.isLicenseDetailPresented = bool
                state.selectedLicense = nil
                
            default:
                break
            }
            return .none
        }
    }
}

extension OpenSourceFeature {
    private func createLicenseList() -> [License] {
        [
            License(
                name: "Alamofire",
                version: "5.10.2",
                licenseType: "MIT License",
                licenseText: """
                Copyright (c) 2014-2024 Alamofire Software Foundation (http://alamofire.org/)

                Permission is hereby granted, free of charge, to any person obtaining a copy
                of this software and associated documentation files (the "Software"), to deal
                in the Software without restriction, including without limitation the rights
                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                copies of the Software, and to permit persons to whom the Software is
                furnished to do so, subject to the following conditions...
                """
            ),
            License(
                name: "AppAuth",
                version: "1.7.6",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "AppCheck",
                version: "11.2.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "combine-schedulers",
                version: "1.0.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "FlowStacks",
                version: "0.4.1",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "GoogleSignIn",
                version: "8.0.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "GoogleUtilities",
                version: "8.0.2",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "GTMAppAuth",
                version: "4.1.1",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "GTMSessionFetcher",
                version: "3.5.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "Kingfisher",
                version: "8.1.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "NMapsGeometry",
                version: "1.0.2",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "NMapsMap",
                version: "3.20.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "PopupView",
                version: "4.0.0",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "Promises",
                version: "2.4.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "Realm",
                version: "10.54.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "RealmDatabase",
                version: "14.13.0",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "swift-case-paths",
                version: "1.5.6",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-clocks",
                version: "1.0.6",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-collections",
                version: "1.1.4",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "swift-composable-architecture",
                version: "1.7.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-concurrency-extras",
                version: "1.3.1",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-custom-dump",
                version: "1.3.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-dependencies",
                version: "1.6.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-identified-collections",
                version: "1.0.0",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-log",
                version: "1.6.2",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "swift-navigation",
                version: "2.2.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-perception",
                version: "1.4.1",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-sharing",
                version: "2.1.0",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "swift-syntax",
                version: "600.0.1",
                licenseType: "Apache License 2.0",
                licenseText: "Apache License 2.0"
            ),
            License(
                name: "swiftui-introspect",
                version: "1.3.0",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "TCACoordinators",
                version: "0.10.1",
                licenseType: "MIT License",
                licenseText: "MIT License"
            ),
            License(
                name: "xctest-dynamic-overlay",
                version: "1.4.3",
                licenseType: "MIT License",
                licenseText: "MIT License"
            )
        ].sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
}
