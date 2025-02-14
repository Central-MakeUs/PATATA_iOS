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
    case deleteSpot(Int)
    case createSpot(CreateSpotRequestDTO)
    case fetchTodaySpotList(Coordinate)
}

extension SpotRouter {
    var method: HTTPMethod {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot, .fetchTodaySpotList:
            return .get
        case .deleteSpot:
            return .delete
        case .createSpot:
            return .post
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
        case let .deleteSpot(spotId):
            return "/spot/\(spotId)"
        case .createSpot:
            return "/spot/create"
        case .fetchTodaySpotList:
            return "/spot/today/list"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot, .deleteSpot, .fetchTodaySpotList:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        case .createSpot:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "multipart/form-data")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchTodayMain, .fetchSpot, .deleteSpot, .createSpot:
            return nil
            
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
            
        case let .fetchSearchResult(searchText, page, latitude, longitude, sortBy):
            return [
                "spotName": searchText,
                "page": page,
                "latitude": latitude,
                "longitude": longitude,
                "sortBy": sortBy
            ]
            
        case let .fetchTodaySpotList(userCoord):
            return [
                "userLatitude": userCoord.latitude,
                "userLongitude": userCoord.longitude
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot, .deleteSpot, .createSpot, .fetchTodaySpotList:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchCategorySpot, .fetchTodayMain, .fetchSearchResult, .fetchSpot, .deleteSpot, .fetchTodaySpotList:
            return .url
            
        case let .createSpot(request):
            let formData = MultipartFormData()
            
            formData.append(
                request.spotName.data(using: .utf8)!,
                withName: "spotName"
            )
            formData.append(
                request.spotAddress.data(using: .utf8)!,
                withName: "spotAddress"
            )
            formData.append(
                request.spotAddressDetail.data(using: .utf8)!,
                withName: "spotAddressDetail"
            )
            
            formData.append(
                String(request.latitude).data(using: .utf8)!,
                withName: "latitude"
            )
            formData.append(
                String(request.longitude).data(using: .utf8)!,
                withName: "longitude"
            )
            formData.append(
                String(request.categoryId).data(using: .utf8)!,
                withName: "categoryId"
            )
            
            formData.append(
                request.spotDescription.data(using: .utf8)!,
                withName: "spotDescription"
            )
            
            let tagsString = request.tags.joined(separator: ",")
            formData.append(
                tagsString.data(using: .utf8)!,
                withName: "tags"
            )
            
            for (index, spotImage) in request.images.enumerated() {
                formData.append(
                    spotImage.file,
                    withName: "images[\(index)].file",
                    fileName: "image_\(index).jpeg",
                    mimeType: "image/jpeg"
                )
                formData.append(
                    String(spotImage.isRepresentative).data(using: .utf8)!,
                    withName: "images[\(index)].isRepresentative"
                )
                formData.append(
                    String(spotImage.sequence).data(using: .utf8)!,
                    withName: "images[\(index)].sequence"
                )
            }
                
            return .multiPart(formData)
        }
    }
}
