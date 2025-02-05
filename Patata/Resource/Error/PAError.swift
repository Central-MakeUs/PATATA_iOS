//
//  PAError.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation

enum PAError: Error {
    case errorMessage(APIError) // 서버에서 던지는 에러코드 대응
    case routerError(RouterError) // routerError
    case networkError(NetworkError) // networkManager Error
    case unwoned(errorStr: String) // 어디서 발생되는지 넣어줘야됨
}
