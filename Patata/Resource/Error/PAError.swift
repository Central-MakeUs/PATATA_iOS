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
    case locationError(APIResponseErrorDTO) // 주소 변환시 발생되는 에러
    case imageResizeError(ImageResizeError) // 이미지 리사이즈 에러
    case unknown(errorStr: String) // 어디서 발생되는지 넣어줘야됨
}
