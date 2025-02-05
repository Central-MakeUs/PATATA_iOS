//
//  RouterError.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

enum RouterError: Error {
    case urlFail(url: String = "")
    case decodingFail
    case encodingFail
    case networkError(error: Error)
    case unknown(error: Error)
}
