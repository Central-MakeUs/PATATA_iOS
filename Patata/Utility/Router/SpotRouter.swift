//
//  SpotRouter.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation
import Alamofire

enum SpotRouter: Router {
    case fetchCategorySpot(categoryId: Int, page: Int, latitude: Double, longitude: Double, sortBy: String)
}

extension SpotRouter {
    var method: HTTPMethod {
        switch self {
        case .fetchCategorySpot:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case let .fetchCategorySpot(categoryId, _, _, _, _):
            return "/spot/category/\(categoryId)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .fetchCategorySpot:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .fetchCategorySpot(_, page, latitude, longitude, sortBy):
            return [
                "page": page,
                "latitude": latitude,
                "longitude": longitude,
                "sortBy": sortBy
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchCategorySpot:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchCategorySpot:
            return .url
        }
    }
}


