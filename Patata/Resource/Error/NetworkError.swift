//
//  NetworkError.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation

enum NetworkError {
    case retryError
    case retryUnowned
    case decodingError
    case timeout
    case noInternet
    case severNotFound
    case unknown(error: Error)
}
