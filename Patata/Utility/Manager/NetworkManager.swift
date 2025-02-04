//
//  NetworkManager.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import Alamofire
import ComposableArchitecture
@preconcurrency import Combine
import Logging

// 나중에 고려해야될 사항
// 네트워크 단절
// 네트워크 일정시간 지속될때

final class NetworkManager: Sendable {
    
    private let networkError = PassthroughSubject<APIResponseError, Never>()
    
    private let cancelStoreActor = AnyValueActor(Set<AnyCancellable>())
    private let retryActor = AnyValueActor(3)
    
    private init() { }
    
    func requestNetwork<T: DTO, R: Router>(dto: T.Type, router: R) async throws(APIError) -> T {
        do {
            let request = try router.asURLRequest()
            
//            Logger.debug(request)
//            Logger.debug(request.url)
            
            let response = await getRequest(dto: dto, router: router, request: request)
            let result = try await getResponse(dto: dto, router: router, response: response)
            
            return result
            
        } catch let routerError as RouterError {
            print("routerError", routerError)
            throw .routerError(routerError)
        } catch let domainError as APIResponseError {
            print("patataError", domainError)
            throw .apiResponseError(domainError)
        } catch {
            throw .unowned
        }
    }
    
    func requestNetworkWithRefresh<T:DTO, R: Router>(dto: T.Type, router: R) async throws(APIError) -> T {
        
        let request = try router.asURLRequest()
        // MARK: 요청담당
        let response = await getRequest(dto: dto, router: router, request: request, ifRefreshMode: true)
        
        let result = try await getResponse(dto: dto, router: router, response: response, ifRefreshMode: true)
        
        return result
    }
    
    func getNetworkError() -> AsyncStream<APIResponseError> {
        
        return AsyncStream<APIResponseError> { contin in
            Task {
                let subscribe = networkError
                    .sink { text in
                        contin.yield(text)
                    }
                
                await cancelStoreActor.withValue { value in
                    value.insert(subscribe)
                }
            }
            
            contin.onTermination = { @Sendable [weak self] _ in
                guard let weakSelf = self else { return }
                Task {
                    await weakSelf.cancelStoreActor.resetValue()
                    contin.finish()
                }
            }
        }
    }
    
}

extension NetworkManager {
    private func getRequest<T: DTO, R: Router>(dto: T.Type, router: R, request: URLRequest, ifRefreshMode: Bool = false) async -> DataResponse<T, AFError> {
            
            if ifRefreshMode {
                let requestResponse = await AF.request(request, interceptor: PARequestInterceptor())
                    .validate(statusCode: 200..<300)
//                    .cURLDescription {
//                        Logger.info($0)
//                    }
                    .serializingDecodable(T.self)
                    .response
//                Logger.debug(requestResponse.debugDescription)
                return requestResponse
            }
            else {
                let requestResponse = await AF.request(request)
                    .validate(statusCode: 200..<300)
                    .serializingDecodable(T.self)
                    .response
//                Logger.debug(requestResponse.debugDescription)
                return requestResponse
            }
        }
    
    private func getResponse<T:DTO>(dto: T.Type, router: Router, response: DataResponse<T, AFError>, ifRefreshMode: Bool = false) async throws(APIResponseError) -> T {
//            Logger.warning(response.response)
//            Logger.warning(response.response ?? "")
            
            switch response.result {
            case let .success(data):
//                Logger.info(data)
                await retryActor.resetValue()
                
                return data
            case let .failure(GBError):
//                Logger.error(response.data?.base64EncodedString() ?? "")
//                Logger.error(GBError)
                do {
                    let retryResult = try await retryNetwork(dto: dto, router: router, ifRefresh: ifRefreshMode)
                    
                    // 성공시 초기화
                    await retryActor.resetValue()
                    
                    return retryResult
                } catch {
                    
                    let check = checkResponseData(response.data, GBError)
                    networkError.send(check)
                    throw check
                }
            }
        }
    
    private func retryNetwork<T: DTO, R: Router>(dto: T.Type, router: R, ifRefresh: Bool) async throws(APIResponseError) -> T {
            let ifRetry = await retryActor.withValue { value in
//                Logger.info("retry Count : \(value)")
                return value > 0
            }
            
            do {
                if ifRetry {
                    let response = try await getRequest(dto: dto, router: router, request: router.asURLRequest())
                    
                    switch response.result {
                    case let .success(data):
                        return data
                    case .failure(let error):
                        await downRetryCount()
                        

                        return try await retryNetwork(dto: dto, router: router, ifRefresh: ifRefresh)
                    }
                } else {
                    throw APIResponseError(isSuccess: false, code: "unknown", message: "unknown")
                }
            } catch {
                throw APIResponseError(isSuccess: false, code: "unknown", message: "unknown")
            }
        }
    
    private func downRetryCount() async {
            await retryActor.withValue { value in
                value -= 1
            }
        }
    
    private func getResponse<T:DTO>(dto: T.Type, router: Router, response: DataResponse<T, AFError>) async throws(APIResponseError) -> T {
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
    
    func checkResponseData(_ responseData: Data?, _ error: AFError) -> APIResponseError {
        if let data = responseData {
            do {
                let errorResponse = try CodableManager.shared.jsonDecoding(model: APIResponseError.self, from: data)
                return errorResponse
            } catch {
                let defaultErrorResponse = APIResponseError(isSuccess: false, code: "unknown", message: "unknown")
                
                return defaultErrorResponse
            }
        } else {
            return APIResponseError(isSuccess: false, code: "unknown", message: "unknown")
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
