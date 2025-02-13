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
    case fetchSearchResult(searchText: String, page: Int, latitude: Double, longitude: Double, sortBy: String)
    case fetchSpot(String)
}

extension SpotRouter {
    var method: HTTPMethod {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchCategorySpot:
            return "/spot/category"
        case .fetchTodayMain:
            return "/spot/today"
        case .fetchSearchResult:
            return "/spot/search"
        case let .fetchSpot(spotId):
            return "/spot/\(spotId)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot:
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
            
        case .fetchTodayMain, .fetchSpot:
            return nil
            
        case let .fetchSearchResult(searchText, page, latitude, longitude, sortBy):
            return [
                "spotName": searchText,
                "page": page,
                "latitude": latitude,
                "longitude": longitude,
                "sortBy": sortBy
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot:
            return .url
        }
    }
}


