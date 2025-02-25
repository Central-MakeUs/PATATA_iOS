//
//  TabCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import TCACoordinators
import ComposableArchitecture

struct TabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<TabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                if #available(iOS 18.0, *) {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        Tab(
                            "홈",
                            image: store.tabState == .home ? "HomeActive" : "HomeInActive",
                            value: .home
                        ) {
                            HomeCoordinatorView(store: store.scope(state: \.homeTabState, action: \.homeTabAction))
                                .tag(TabCase.home)
                        }
                        
                        Tab(
                            "내주변",
                            image: store.tabState == .map ? "SpotActive" : "SpotInActive",
                            value: .map
                        ) {
                            MapCoordinatorView(store: store.scope(state: \.mapTabState, action: \.mapTabAction))
                                .tag(TabCase.map)
                                .ignoresSafeArea(.all, edges: .bottom)
                        }
                        
                        Tab(
                            "아카이브",
                            image: store.tabState == .archive ? "ArchiveActiveTap" : "ArchiveInActiveTap",
                            value: .archive
                        ) {
                            ArchiveCoordinatorView(store: store.scope(state: \.archiveTabState, action: \.archiveTabAction))
                                .tag(TabCase.archive)
                                .ignoresSafeArea(.all, edges: .bottom)
                        }
                        
                        Tab(
                            "My",
                            image: store.tabState == .myPage ? "MyPageActive" : "MyPageInActive",
                            value: .myPage
                        ) {
                            MyPageCoordinatorView(store: store.scope(state: \.myPageTabState, action: \.myPageTabAction))
                                .tag(TabCase.myPage)
                                .ignoresSafeArea(.all, edges: .bottom)
                        }
                    }
                    .tint(.textDefault)
                    .onAppear {
                        let image = UIImage.gradientImageWithBounds(
                            bounds: CGRect( x: 0, y: 0, width: UIScreen.main.scale, height: 8),
                            colors: [
                                UIColor.clear.cgColor,
                                UIColor.black.withAlphaComponent(0.012).cgColor
                            ]
                        )
                        
                        let standardAppearance = UITabBarAppearance()
                        standardAppearance.configureWithDefaultBackground()
                        standardAppearance.backgroundColor = .white
                        standardAppearance.backgroundImage = UIImage()
                        standardAppearance.shadowImage = image
                        
                        let scrollEdgeAppearance = UITabBarAppearance()
                        scrollEdgeAppearance.configureWithTransparentBackground()
                        scrollEdgeAppearance.backgroundColor = .white
                        scrollEdgeAppearance.backgroundImage = UIImage()
                        scrollEdgeAppearance.shadowImage = image
                        
                        UITabBar.appearance().standardAppearance = standardAppearance
                        UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
                    }
                } else {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        HomeCoordinatorView(store: store.scope(state: \.homeTabState, action: \.homeTabAction))
                            .tabItem {
                                Image(store.tabState == .home ? "HomeActive" : "HomeInActive")
                            }
                            .tag(TabCase.home)
                            
                        MapCoordinatorView(store: store.scope(state: \.mapTabState, action: \.mapTabAction))
                            .tabItem {
                                Image(store.tabState == .map ?  "SpotActive" : "SpotInActive")
                            }
                            .tag(TabCase.map)
                            .ignoresSafeArea(.all, edges: .bottom)
                        
                        ArchiveCoordinatorView(store: store.scope(state: \.archiveTabState, action: \.archiveTabAction))
                            .tabItem {
                                Image(store.tabState == .archive ?  "ArchiveActiveTap" : "ArchiveInActiveTap")
                            }
                            .tag(TabCase.archive)
                            .ignoresSafeArea(.all, edges: .bottom)
                        
                        MyPageCoordinatorView(store: store.scope(state: \.myPageTabState, action: \.myPageTabAction))
                            .tabItem {
                                Image(store.tabState == .myPage ?  "MyPageActive" : "MyPageInActive")
                            }
                            .tag(TabCase.myPage)
                            .ignoresSafeArea(.all, edges: .bottom)
                    }
                    .tint(.textDefault)
                    .onAppear {
                        let image = UIImage.gradientImageWithBounds(
                            bounds: CGRect( x: 0, y: 0, width: UIScreen.main.scale, height: 8),
                            colors: [
                                UIColor.clear.cgColor,
                                UIColor.black.withAlphaComponent(0.05).cgColor
                            ]
                        )
                        
                        let standardAppearance = UITabBarAppearance()
                        standardAppearance.configureWithDefaultBackground()
                        standardAppearance.backgroundColor = .white
                        standardAppearance.backgroundImage = UIImage()
                        standardAppearance.shadowImage = image
                        
                        let scrollEdgeAppearance = UITabBarAppearance()
                        scrollEdgeAppearance.configureWithTransparentBackground()
                        scrollEdgeAppearance.backgroundColor = .white
                        scrollEdgeAppearance.backgroundImage = UIImage()
                        scrollEdgeAppearance.shadowImage = image
                        
                        UITabBar.appearance().standardAppearance = standardAppearance
                        UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
                    }
                }
            }
        }
    }
}
