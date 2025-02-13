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
    
    private let networkError = PassthroughSubject<PAError, Never>()
    
    private let cancelStoreActor = AnyValueActor(Set<AnyCancellable>())
    private let retryActor = AnyValueActor(3)
    
    private init() { }
    
    func requestNetwork<T: DTO, R: Router>(dto: T.Type, router: R) async throws(PAError) -> T {
        let request = try router.asURLRequest()
        
        //            Logger.debug(request)
        //            Logger.debug(request.url)
        
        let response = await getRequest(dto: dto, router: router, request: request)
        let result = try await getResponse(dto: dto, router: router, response: response)
        
        return result
    }
    
    func requestNetworkWithRefresh<T:DTO, R: Router>(dto: T.Type, router: R) async throws(PAError) -> T {
        let request = try router.asURLRequest()
        // MARK: 요청담당
        let response = await getRequest(dto: dto, router: router, request: request, ifRefreshMode: true)
        
        let result = try await getResponse(dto: dto, router: router, response: response, ifRefreshMode: true)
        
        return result
    }
    
    func getNetworkError() -> AsyncStream<PAError> {
        
        return AsyncStream<PAError> { contin in
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
                    .cURLDescription { curl in  // 여기 추가
                        print("🚀 cURL:", curl)
                    }
                    .serializingDecodable(T.self)
                    .response
//                Logger.debug(requestResponse.debugDescription)
                return requestResponse
            }
            else {
                let requestResponse = await AF.request(request)
                    .validate(statusCode: 200..<300)
                    .cURLDescription { curl in  // 여기 추가
                        print("🚀 cURL:", curl)
                    }
                    .serializingDecodable(T.self)
                    .response
//                Logger.debug(requestResponse.debugDescription)
                return requestResponse
            }
        }
    
    private func getResponse<T:DTO>(dto: T.Type, router: Router, response: DataResponse<T, AFError>) async throws(PAError) -> T {
        switch response.result {
        case let .success(data):
            
            return data
        case let .failure(patataError):
            print("AFError details:", patataError.localizedDescription)
            print("AFError underlying error:", patataError.underlyingError ?? "nil")
            print("Response status code:", response.response?.statusCode ?? "nil")
//            let check = checkResponseData(response.data, patataError)
//            networkError.send(check)
            throw checkResponseData(response.data, patataError)
        }
    }
    
    private func getResponse<T:DTO>(dto: T.Type, router: Router, response: DataResponse<T, AFError>, ifRefreshMode: Bool = false) async throws(PAError) -> T {
//            Logger.warning(response.response)
//            Logger.warning(response.response ?? "")
        print("🔍 Response Data:", String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")
           print("📝 Response Status Code:", response.response?.statusCode ?? -1)
            switch response.result {
            case let .success(data):
//                Logger.info(data)
                await retryActor.resetValue()
                
                return data
            case let .failure(patataError):
//                Logger.error(response.data?.base64EncodedString() ?? "")
//                Logger.error(GBError)
                print("❌ Error Response Data:", String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")
                    print("❌ Error Status Code:", response.response?.statusCode ?? -1)
                    print("❌ Error Details:", patataError)
                
                do {
                    let retryResult = try await retryNetwork(dto: dto, router: router, ifRefresh: ifRefreshMode)
                    
                    // 성공시 초기화
                    await retryActor.resetValue()
                    
                    return retryResult
                } catch {
                    let check = checkResponseData(response.data, patataError)
                    networkError.send(check)
                    throw check
                }
            }
        }
    
    private func retryNetwork<T: DTO, R: Router>(dto: T.Type, router: R, ifRefresh: Bool) async throws(PAError) -> T {
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
                case let .failure(error):
                    await downRetryCount()
                    
                    return try await retryNetwork(dto: dto, router: router, ifRefresh: ifRefresh)
                }
            } else {
                throw PAError.networkError(.retryError)
            }
        } catch {
            throw .networkError(.retryUnowned)
        }
    }
    
    private func downRetryCount() async {
            await retryActor.withValue { value in
                value -= 1
            }
        }
    

    
    private func checkResponseData(_ responseData: Data?, _ error: AFError) -> PAError {
        if let data = responseData {
            do {
                let errorResponse = try CodableManager.shared.jsonDecoding(model: APIResponseErrorDTO.self, from: data)
                
                guard let apiError = APIError.getType(code: errorResponse.code) else {
                    // code가 없을때
                    return .errorMessage(.unknown(errorResponse))
                }
                
                return .errorMessage(apiError)
                
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("서버 응답 데이터:", jsonString)
                }
                print("errorModelDecoding", error)
                
                return PAError.networkError(.decodingError)
            }
        } else {
            return catchURLError(error)
        }
    }
    
    private func catchURLError(_ error: AFError) -> PAError {
        if let afError = error.asAFError, let urlError = afError.underlyingError as? URLError {
            switch urlError.code {
            case .timedOut:
                networkError.send(.networkError(.timeout))
                
                return .networkError(.timeout)
                
            case .notConnectedToInternet:
                networkError.send(.networkError(.noInternet))
                
                return .networkError(.noInternet)
                
            case .cannotFindHost, .cannotConnectToHost:
                networkError.send(.networkError(.severNotFound))
                
                return .networkError(.severNotFound)
                
            default:
                print("❌ Unhandled URLError: \(urlError.code) - \(urlError.localizedDescription)")
                
                networkError.send(.networkError(.unknown(error: urlError)))
                
                return .networkError(.unknown(error: urlError))
            }
        } else {
            print("❌ Unknown AFError: \(error.localizedDescription)")
            
            networkError.send(.networkError(.unknown(error: error)))
            
            return .networkError(.unknown(error: error))
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
