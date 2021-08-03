//
//  NetworkManager.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 17.07.2021..
//

import Foundation
import Alamofire

class NetworkManager {

    static let sharedInstance = NetworkManager()

    let session: Session
    var authInfo: AuthInfo? = nil
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        session = Session(configuration: configuration)
    }

    func call<T>(type: EndPointType, onResult: @escaping (Result<(T, [String: String]?), Error>)->()) where T: Codable {
        self.session
            .request(type)
            .validate()
            .responseDecodable(of: T.self) { response in
                let headers = response.response?.allHeaderFields as? [String: String]

                switch response.result {
                case .success(let response):
                    let result = (response, headers)
                    onResult(.success(result))
                    break
                case .failure(let error):
                    onResult(.failure(error))
                    break
                }
            }
    }

    func callWithMultipartFormData<T>(type: EndPointType, multipartFormData: MultipartFormData, onResult: @escaping (Result<(T, [String: String]?), Error>) -> Void) where T: Codable {
        do {
            AF
                .upload(
                    multipartFormData: multipartFormData,
                    to: try type.baseURL.asURL().appendingPathComponent(type.path).absoluteString,
                    method: .put,
                    headers: HTTPHeaders(type.headers)
                )
                .validate()
                .responseDecodable(of: T.self) { response in
                    let headers = response.response?.allHeaderFields as? [String: String]

                    switch response.result {
                    case .success(let response):
                        let result = (response, headers)
                        onResult(.success(result))
                        break
                    case .failure(let error):
                        onResult(.failure(error))
                        break
                    }
                }
        } catch {
            return
        }
    }
}

protocol EndPointType : URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var params: [String: String]? { get }
    var headers: [String: String] { get }
    var queryParams: [String: String] { get }
}

extension EndPointType {
    var headers: [String: String] {
        return [:]
    }
    var params: [String: String]? {
        return nil
    }
    var queryParams: [String: String] {
        return [:]
    }
}

extension EndPointType {

    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: try baseURL.asURL().appendingPathComponent(path))

        var components = URLComponents(
            string: try baseURL.asURL().appendingPathComponent(path).absoluteString
        )
        components?.queryItems = queryParams.map { element in
            URLQueryItem(name: element.key, value: element.value)
        }

        guard let url = try components?.url?.absoluteString.asURL() else {
            throw NSError()
        }
        
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.headers = HTTPHeaders(headers)

        return try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
    }
}
