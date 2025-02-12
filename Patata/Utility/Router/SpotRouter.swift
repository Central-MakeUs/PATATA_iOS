//
//  SpotRouter.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation
import Alamofire

enum SpotRouter: Router {
    case fetchCategorySpot(all: Bool, categoryId: Int, page: Int, latitude: Double, longitude: Double, sortBy: String)
    case fetchTodayMain
}

extension SpotRouter {
    var method: HTTPMethod {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchCategorySpot:
            return "/spot/category"
        case .fetchTodayMain:
            return "/spot/today"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .fetchCategorySpot(all, categoryId, page, latitude, longitude, sortBy):
            if all {
                return [
                    "page": page,
                    "latitude": latitude,
                    "longitude": longitude,
                    "sortBy": sortBy
                    ]
            }
            
            return [
                "page": page,
                "latitude": latitude,
                "longitude": longitude,
                "sortBy": sortBy,
                "categoryId": categoryId
            ]
            
        case .fetchTodayMain:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain:
            return .url
        }
    }
}


