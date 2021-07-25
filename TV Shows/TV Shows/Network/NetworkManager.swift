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
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        session = Session(configuration: configuration)
    }
    
    func call<T>(type: EndPointType, onResult: @escaping (Result<T, Error>)->()) where T: Codable {
        self.session
            .request(type)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let response):
                    onResult(.success(response))
                    break
                case .failure(let error):
                    onResult(.failure(error))
                    break
                }
            }
    }
}

protocol EndPointType : URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var params: [String: String] { get }
}

extension EndPointType {

    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: try baseURL.asURL().appendingPathComponent(path))
        urlRequest.httpMethod = httpMethod.rawValue
        return try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
    }
}
