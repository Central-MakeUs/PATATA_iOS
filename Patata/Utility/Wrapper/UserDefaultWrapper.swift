//
//  UserDefaultWrapper.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    let key: String
    let placeValue: T
    
    private let userDefaults = UserDefaults.standard
    
    var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key),
                  let value = try? CodableManager.shared.jsonDecoding(model: T.self, from: data) else {
                return placeValue
            }
            return value
        } set {
            guard let data = try? CodableManager.shared.jsonEncoding(from: newValue)
            else {
                return
            }
            userDefaults.setValue(data, forKey: key)
        }
    }
}
