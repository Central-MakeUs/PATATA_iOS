//
//  PARequestInterceptor.swift
//  Patata
//
//  Created by 김진수 on 2/5/25.
//

import Foundation
import Alamofire

final class PARequestInterceptor: RequestInterceptor {
    
    private let retryCount = AnyValueActor(3)
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: UserDefaultsManager.accessToken))
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        Task {
            
            // 상태
            guard let statusCode = request.response?.statusCode else {
                completion(.doNotRetry)
                return
            }
            
            if statusCode == 401 && !UserDefaultsManager.refreshToken.isEmpty {
                print("heheheheheheh")
                if await requestRefresh() {
                    completion(.retry)
                } else {
                    completion(.doNotRetry)
                }
            } else {
                print("statuscode", statusCode)
                print("hereh?")
                completion(.doNotRetry)
            }

        }
    }
    
    private func requestRefresh() async -> Bool {
        
        let retryCurrent = await retryCount.withValue {
           return $0 > 0
        }
        
        if !retryCurrent { return false }
        
        let result = try? await NetworkManager.shared.requestNetwork(
            dto: LoginDTO.self,
            router: LoginRouter.refresh(
                refreshToken: UserDefaultsManager.refreshToken
            )
        )
        
        guard let result else { return false }
        print("successAccess", result.result.accessToken)
        print("successRefresh", result.result.refreshToken)
        UserDefaultsManager.accessToken = result.result.accessToken
        UserDefaultsManager.refreshToken = result.result.refreshToken
        await retryCount.withValue { num in
            num -= 1
        }
        return true
    }
    
}
