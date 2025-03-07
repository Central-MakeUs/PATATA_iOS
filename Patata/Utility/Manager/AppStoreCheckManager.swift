//
//  AppStoreCheckManager.swift
//  Patata
//
//  Created by 김진수 on 3/7/25.
//

import Foundation
import UIKit

final class AppStoreCheckManager {
    // 현재 버전 : 타겟 -> 일반 -> Version
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    // 개발자가 내부적으로 확인하기 위한 용도 : 타겟 -> 일반 -> Build
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    static let appStoreOpenUrlString = "itms-apps://apps.apple.com/app/id6742177268"
    
    // 앱 스토어 최신 정보 확인
    func latestVersion() async -> String? {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=6742177268&country=kr") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let jsonData =  CodableManager.shared.toJSONSerialization(data: data) as? [String: Any] else {
                print("AppStore json Error")
                return nil
            }
            
            guard let results = jsonData["results"] as? [[String: Any]],
                  let appStoreVersion = results.first?["version"] as? String
            else {
                print("AppStore results Error")
                return nil
            }
            
            return appStoreVersion
        } catch {
            print("네트워크 요청 실패: \(error)")
        }
        
        return nil
    }
    
    // 앱 스토어로 이동 -> urlStr 에 appStoreOpenUrlString 넣으면 이동
    func openAppStore() {
        guard let url = URL(string: AppStoreCheckManager.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
