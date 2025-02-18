//
//  OpenSourceView.swift
//  Patata
//
//  Created by 김진수 on 2/19/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct OpenSourceView: View {
    @Perception.Bindable var store: StoreOf<OpenSourceFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden()
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

struct LicenseDetailView: View {
    let license: License
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text(license.name)
                        .font(.title2)
                        .bold()
                    
                    Text("버전: \(license.version)")
                        .font(.subheadline)
                    
                    Text("라이선스: \(license.licenseType)")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                Text(license.licenseText)
                    .font(.body)
                    .lineSpacing(4)
            }
            .padding()
        }
    }
}

extension OpenSourceView {
    private var contentView: some View {
        VStack {
            fakeNavBar
            
            List {
                Section {
                    Text("버전 \(store.appVersion)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    ForEach(store.licenses) { license in
                        Button {
                            store.send(.viewEvent(.tappedLicense(license)))
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(license.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("v\(license.version)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .sheet(
                isPresented: $store.isLicenseDetailPresented.sending(\.binding)
            ) {
                if let selectedLicense = store.selectedLicense {
                    NavigationStack {
                        LicenseDetailView(license: selectedLicense)
                            .navigationTitle(selectedLicense.name)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
    }
    
    private var fakeNavBar: some View {
        ZStack {
            HStack {
                NavBackButton {
                    store.send(.viewEvent(.tappedBackButton))
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text("오픈소스 라이선스")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
}
