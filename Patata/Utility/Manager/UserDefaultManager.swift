//
//  UserDefaultManager.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation

final actor UserDefaultsManager {
    
    enum Key: String {
        case isFirst
        case accessToken
        case refreshToken
        case nickname
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.isFirst.value, placeValue: true)
    static var isFirst: Bool
    @UserDefaultsWrapper(key: Key.accessToken.value, placeValue: "")
    static var accessToken
    @UserDefaultsWrapper(key: Key.refreshToken.value, placeValue: "")
    static var refreshToken
    @UserDefaultsWrapper(key: Key.nickname.value, placeValue: "")
    static var nickname
}
