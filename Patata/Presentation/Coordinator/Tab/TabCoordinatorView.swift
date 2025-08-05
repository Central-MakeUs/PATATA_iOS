//
//  TabCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

struct TabCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<TabCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                if #available(iOS 18.0, *) {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        Tab(
                            "홈",
                            image: store.tabState == .home ? "HomeActive" : "HomeInActive",
                            value: .home
                        ) {
                            HomeCoordinatorView(store: store.scope(state: \.home, action: \.home))
                                .tag(TabCase.home)
                                .hideTabBar(store.isHidden)
                        }
                        
                        Tab(
                            "내주변",
                            image: store.tabState == .map ? "SpotActive" : "SpotInActive",
                            value: .map
                        ) {
                            MapCoordinatorView(store: store.scope(state: \.map, action: \.map))
                                .tag(TabCase.map)
                                .ignoresSafeArea(.all, edges: .bottom)
                                .hideTabBar(store.isHidden)
                        }
                        
                        Tab(
                            "아카이브",
                            image: store.tabState == .archive ? "ArchiveActiveTap" : "ArchiveInActiveTap",
                            value: .archive
                        ) {
                            ArchiveCoordinatorView(store: store.scope(state: \.archive, action: \.archive))
                                .tag(TabCase.archive)
                                .ignoresSafeArea(.all, edges: .bottom)
                                .hideTabBar(store.isHidden)
                        }
                        
                        Tab(
                            "My",
                            image: store.tabState == .myPage ? "MyPageActive" : "MyPageInActive",
                            value: .myPage
                        ) {
                            MyPageCoordinatorView(store: store.scope(state: \.myPage, action: \.myPage))
                                .tag(TabCase.myPage)
                                .ignoresSafeArea(.all, edges: .bottom)
                                .hideTabBar(store.isHidden)
                        }
                    }
                } else {
                    TabView(selection: $store.tabState.sending(\.bindingTab)) {
                        HomeCoordinatorView(store: store.scope(state: \.home, action: \.home))
                            .tabItem {
                                Image(store.tabState == .home ? "HomeActive" : "HomeInActive")
                            }
                            .tag(TabCase.home)
                            .hideTabBar(store.isHidden)
                        
                        MapCoordinatorView(store: store.scope(state: \.map, action: \.map))
                            .tabItem {
                                Image(store.tabState == .map ?  "SpotActive" : "SpotInActive")
                            }
                            .tag(TabCase.map)
                            .ignoresSafeArea(.all, edges: .bottom)
                            .hideTabBar(store.isHidden)
                        
                        ArchiveCoordinatorView(store: store.scope(state: \.archive, action: \.archive))
                            .tabItem {
                                Image(store.tabState == .archive ?  "ArchiveActiveTap" : "ArchiveInActiveTap")
                            }
                            .tag(TabCase.archive)
                            .ignoresSafeArea(.all, edges: .bottom)
                            .hideTabBar(store.isHidden)
                        
                        MyPageCoordinatorView(store: store.scope(state: \.myPage, action: \.myPage))
                            .tabItem {
                                Image(store.tabState == .myPage ?  "MyPageActive" : "MyPageInActive")
                            }
                            .tag(TabCase.myPage)
                            .ignoresSafeArea(.all, edges: .bottom)
                            .hideTabBar(store.isHidden)
                    }
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
                let blurEffect = UIBlurEffect(style: .light)
                standardAppearance.configureWithDefaultBackground()
                standardAppearance.backgroundEffect = blurEffect
                standardAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.80)
                standardAppearance.backgroundImage = UIImage()
                standardAppearance.shadowImage = image
                
                let scrollEdgeAppearance = UITabBarAppearance()
                scrollEdgeAppearance.configureWithTransparentBackground()
                scrollEdgeAppearance.backgroundEffect = blurEffect
                scrollEdgeAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.80)
                scrollEdgeAppearance.shadowImage = image
                
                UITabBar.appearance().standardAppearance = standardAppearance
                UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
            }
        }
    }
}
