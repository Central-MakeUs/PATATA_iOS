//
//  Router.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation
import Alamofire

enum EncodingType {
    case url
    case json
    case multiPart(MultipartFormData)
}

protocol Router {
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
//    var defaultHeader: HTTPHeaders { get }
    var optionalHeaders: HTTPHeaders? { get } // secretHeader 말고도 추가적인 헤더가 필요시
    var headers: HTTPHeaders { get } // 다 합쳐진 헤더
    var parameters: Parameters? { get }
    var body: Data? { get }
    var encodingType: EncodingType { get }
}

extension Router {
    
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var headers: HTTPHeaders {
        var combine = HTTPHeaders()
        if let optionalHeaders {
            optionalHeaders.forEach { header in
                combine.add(header)
            }
        }
        return combine
    }
    
    func asURLRequest() throws(PAError) -> URLRequest {
        let url = try baseURLToURL()
        
        var urlRequest = try urlToURLRequest(url: url)
        
        switch encodingType {
        case .url:
            do {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
                
                return urlRequest
            } catch {
                throw .routerError(.encodingFail)
            }
        case .json:
            do {
                let jsonObject = CodableManager.shared.toJSONSerialization(data: body)
                urlRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: jsonObject)
                return urlRequest
            } catch {
                throw .routerError(.decodingFail)
            }
            
        case .multiPart:
//            do {
//                let boundary = "Boundary-\(UUID().uuidString)"
//                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//                
//                urlRequest.httpBody = try formData.encode()
//                
//                return urlRequest
//            } catch {
//                throw .routerError(.encodingFail)
//            }
            return urlRequest
        }
    }
    
    private func baseURLToURL() throws(PAError) -> URL {
        do {
            let url = try baseURL.asURL()
            return url
        } catch let error as AFError {
            switch error {
            case .invalidURL:
                throw PAError.routerError(.urlFail(url: baseURL))
            case .parameterEncodingFailed, .multipartEncodingFailed:
                throw PAError.routerError(.encodingFail)
            default:
                throw PAError.routerError(.networkError(error: error))
            }
        }catch {
            throw PAError.routerError(.unknown(error: error))
        }
    }
    
    private func urlToURLRequest(url: URL) throws(PAError) -> URLRequest {
        do {
            let urlRequest = try URLRequest(url: url.appending(path: path), method: method, headers: headers)
            return urlRequest
        } catch let error as AFError {
            switch error {
            case .invalidURL:
                throw PAError.routerError(.urlFail(url: baseURL))
            case .parameterEncodingFailed:
                throw PAError.routerError(.encodingFail)
            default:
                throw PAError.routerError(.networkError(error: error))
            }
        } catch {
            throw PAError.routerError(.unknown(error: error))
        }
    }

    func requestToBody(_ request: Encodable) -> Data? {
        do {
            return try CodableManager.shared.jsonEncoding(from: request)
        } catch {
            #if DEBUG
            print("requestToBody Error")
            #endif
            return nil
        }
    }
}

