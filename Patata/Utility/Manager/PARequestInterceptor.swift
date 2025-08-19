//
//  PARequestInterceptor.swift
//  Patata
//
//  Created by 김진수 on 2/5/25.
//

import Foundation
import Alamofire

final class PARequestInterceptor: RequestInterceptor {
    
    private let gate = RefreshGate()
    private let maxRetryPerRequest = 1
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: UserDefaultsManager.accessToken))
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < maxRetryPerRequest else {
            completion(.doNotRetry)
            return
        }
        
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        
        if statusCode == 401, !UserDefaultsManager.refreshToken.isEmpty {
            Task {
                let isValid = await requestRefresh()
                completion(isValid ? .retry : .doNotRetry)
            }
            return
        }
    }
    
    private func requestRefresh() async -> Bool {
        return await gate.run {
            let dto = try? await NetworkManager.shared.requestNetwork(
                dto: LoginDTO.self,
                router: LoginRouter.refresh(refreshToken: UserDefaultsManager.refreshToken)
            )
            guard let dto else { return false }
            
            UserDefaultsManager.accessToken  = dto.result.accessToken
            UserDefaultsManager.refreshToken = dto.result.refreshToken
            return true
        }
    }
}

actor RefreshGate {
    private var task: Task<Bool, Never>?
    
    func run(_ operation: @escaping () async -> Bool) async -> Bool {
        if let existingTask = task {
            return await existingTask.value     // 이미 진행 중이면 결과만 기다림
        }
        
        let newTask = Task { await operation() }
        task = newTask
        let result = await newTask.value
        task = nil
        return result
    }
}

