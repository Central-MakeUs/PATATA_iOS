//
//  MapRouter.swift
//  Patata
//
//  Created by 김진수 on 2/15/25.
//

import Foundation
import Alamofire

enum MapRouter: Router {
    case fetchMap(
        mbrLocation: MBRCoordinates,
        userLocation: Coordinate,
        categoryId: Int,
        isSearch: Bool
    )
    
    case checkSpotCount(Coordinate)
}

extension MapRouter {
    var method: HTTPMethod {
        switch self {
        case .fetchMap, .checkSpotCount:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchMap:
            return "/map/in-bound"
        case .checkSpotCount:
            return "/map/density"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .fetchMap, .checkSpotCount:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .fetchMap(mbrLocation, userLocation, categoryId, isSearch):
            if categoryId != 0 {
                return [
                    "minLatitude": mbrLocation.southWest.latitude,
                    "minLongitude": mbrLocation.southWest.longitude,
                    "maxLatitude": mbrLocation.northEast.latitude,
                    "maxLongitude": mbrLocation.northEast.longitude,
                    "userLatitude": userLocation.latitude,
                    "userLongitude": userLocation.longitude,
                    "categoryId": categoryId,
                    "withSearch": isSearch
                ]
            } else {
                return [
                    "minLatitude": mbrLocation.southWest.latitude,
                    "minLongitude": mbrLocation.southWest.longitude,
                    "maxLatitude": mbrLocation.northEast.latitude,
                    "maxLongitude": mbrLocation.northEast.longitude,
                    "userLatitude": userLocation.latitude,
                    "userLongitude": userLocation.longitude,
                    "withSearch": isSearch
                ]
            }
            
        case let .checkSpotCount(coord):
            return [
                "latitude": coord.latitude,
                "longitude": coord.longitude
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchMap, .checkSpotCount:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchMap, .checkSpotCount:
            return .url
        }
    }
}

