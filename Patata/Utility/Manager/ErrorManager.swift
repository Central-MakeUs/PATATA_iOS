//
//  ErrorManager.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation
import ComposableArchitecture

final class ErrorManager: Sendable {
    func handleError(_ error: Error) -> String? {
        let paError = convertToPAError(error)
        return handlePAError(paError)
    }
    
    func checkTokenError(_ error: Error) -> Bool {
        let paError = convertToPAError(error)
        
        if case .errorMessage(let apiError) = paError {
            if case .token(let tokenError) = apiError {
                switch tokenError {
                case .invalidAccessToken:
                    return true  // 액세스 토큰 만료는 자동 갱신 처리
                case .tokenNotExist, .invalidTokenFormat, .invalidRefreshToken:
                    return true   // 로그인 화면으로 리다이렉션 필요
                }
            }
        }
        return false
    }
    
    
}

extension ErrorManager {
    private func convertToPAError(_ error: Error) -> PAError {
        if let paError = error as? PAError {
            return paError
        } else {
            return .unknown(errorStr: "unknown error: \(error.localizedDescription)")
        }
    }
    
    private func handlePAError(_ error: PAError) -> String? {
        switch error {
        case .errorMessage(let apiError):
            return handleAPIError(apiError)
            
        case .networkError(let networkError):
            return handleNetworkError(networkError)
            
        case .routerError(let routerError):
            return handleRouterError(routerError)
            
        case .locationError(let locationError):
            print("loactionError", locationError)
            return "잠시후 다시 이용해주세요"
            
        case .imageResizeError(let imageResizeError):
            return handleImageResizeError(imageResizeError)
            
        case .checkAddSpot(let error):
            print("checkAddSpot")
            return nil
            
        case .unknown(let errorStr):
            print("해결 시급합니다!! \(errorStr)")
            return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    private func handleAPIError(_ apiError: APIError) -> String? {
        switch apiError {
        case .token(let tokenError):
            switch tokenError {
            case .tokenNotExist:
                print("토큰이 존재하지 않습니다.")
            case .invalidTokenFormat:
                print("유효하지 않은 토큰 형식입니다.")
            case .invalidAccessToken:
                print("에세스 토큰 재갱신")
            case .invalidRefreshToken:
                print("리프레쉬 토큰 만료")
                
            }
            return nil
        case .member(let memberError):
            switch memberError {
            case .usedNickname:
                return "이미 사용중인 닉네임입니다."
            }
            
        case .common(let commonError):
            switch commonError {
            case .success:
                print("성공 근데 왜 에러야 확인해봐!!!!!!")
                return nil
            case .invalidRequest:
                return "잘못된 요청입니다. 다시 시도해주세요."
            }
            
        case .oauth(let oAuthError):
            switch oAuthError {
            case .failApplelogin:
                // 언제 애플 로그인 실패인지 확인해보자
                return "Apple 로그인에 실패했습니다."
            }
            
        case .search(let searchError):
            switch searchError {
            case .noData:
                print("검색어에 대한 정보 없음")
                return ""
            }
            
        case .unknown(let apiResponseErrorDTO):
            print("해당 에러 추가해줘야돼 모르는 에러등장", apiResponseErrorDTO)
            return nil
        }
    }
    
    private func handleNetworkError(_ networkError: NetworkError) -> String {
        switch networkError {
        case .timeout:
            return "요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요."
        case .noInternet:
            return "인터넷 연결을 확인해주세요."
        case .severNotFound:
            return "서버에 연결할 수 없습니다."
        case .retryError, .retryUnowned:
            return "네트워크 상태가 불안정합니다.\n잠시 후 다시 시도해주세요."
        case .decodingError:
            print("디코딩 에러 등장했어 확인해봐")
            return "해당 에러는 개발자 잘못입니다 문의해주세요"
        case .unknown:
            print("NetworkError 어떤 에러인지 파악해봐 비상이야!!!")
            return "네트워크 오류가 발생했습니다. 문의해주세요"
        }
    }
    
    private func handleRouterError(_ routerError: RouterError) -> String? {
        switch routerError {
        case .urlFail:
            print("router 에러터짐 url이야")
            return nil
        case .decodingFail, .encodingFail:
            print("router decoding encoding에서 터짐 확인해봐")
            return nil
        case .networkError, .unknown:
            print("router에서 모르는 에러 발생 확인해봐!!!")
            return "네트워크 오류가 발생했습니다. 문의해주세요"
        }
    }
    
    private func handleImageResizeError(_ imageResizeError: ImageResizeError) -> String {
        switch imageResizeError {
        case .totalSizeExceeded:
            return "전체 이미지 크기가 10MB를 초과합니다."
        case .invalidImage:
            return "이미지 처리 중 오류가 발생했습니다."
        }
    }
}

extension ErrorManager {
    static let shared = ErrorManager()
}

extension ErrorManager: DependencyKey {
    static let liveValue: ErrorManager = ErrorManager.shared
}

extension DependencyValues {
    var errorManager: ErrorManager {
        get { self[ErrorManager.self] }
        set { self[ErrorManager.self] = newValue }
    }
}
