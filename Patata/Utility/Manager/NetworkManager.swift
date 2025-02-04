//
//  NetworkManager.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import Alamofire
import ComposableArchitecture

// 나중에 고려해야될 사항
// 네트워크 단절
// 네트워크 일정시간 지속될때

final class NetworkManager: Sendable {
    
    private init() { }
    
    func requestNetwork<T: DTO, R: Router>(dto: T.Type, router: R) async throws(APIError) -> T {
        do {
            let request = try router.asURLRequest()
            let response = await getRequest(dto: dto, router: router, request: request)
            let result = try await getResponse(dto: dto, router: router, response: response)
            
            return result
            
        } catch let routerError as RouterError {
            print("routerError", routerError)
            throw .routerError(routerError)
        } catch let domainError as DomainError {
            print("patataError", domainError)
            throw .domainError(domainError)
        } catch {
            throw .unowned
        }
    }
}

extension NetworkManager {
    private func getRequest<T: DTO, R: Router>(dto: T.Type, router: R, request: URLRequest) async -> DataResponse<T, AFError> {
        return await AF.request(request)
            .cacheResponse(using: .cache)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .response
    }
    
    private func getResponse<T:DTO>(dto: T.Type, router: Router, response: DataResponse<T, AFError>) async throws(DomainError) -> T {
        switch response.result {
        case let .success(data):
            
            return data
        case let .failure(patataError):
            print("AFError details:", patataError.localizedDescription)
                print("AFError underlying error:", patataError.underlyingError ?? "nil")
                print("Response status code:", response.response?.statusCode ?? "nil")
            throw checkResponseData(response.data, patataError)
        }
    }
    
    private func checkResponseData(_ responseData: Data?, _ error: AFError) -> DomainError {
        if let data = responseData {
            do {
                let errorResponse = try CodableManager.shared.jsonDecoding(model: DomainError.self, from: data)
                return errorResponse
            } catch {
                let defaultErrorResponse = DomainError(isSuccess: false, code: "unknown", message: "unknown")
                
                return defaultErrorResponse
            }
        } else {
            return DomainError(isSuccess: false, code: "unknown", message: "unknown")
        }
    }
}

extension NetworkManager {
    static let shared = NetworkManager()
}

extension NetworkManager: DependencyKey {
    static let liveValue: NetworkManager = NetworkManager.shared
}

extension DependencyValues {
    var networkManager: NetworkManager {
        get { self[NetworkManager.self] }
        set { self[NetworkManager.self] = newValue }
    }
}
