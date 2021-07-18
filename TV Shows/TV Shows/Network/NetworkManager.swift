//
//  NetworkManager.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 17.07.2021..
//

import Foundation
import Alamofire

class NetworkManager {
    
    let session: Session
    
    init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.allowsCellularAccess = false
        session = Session(configuration: configuration)
    }
    
    func call<T>(type: EndPointType, params: [String: String], onSuccess: @escaping (T)->(), onFailure: @escaping (Error) -> Void) where T: Codable {
        self.session
            .request(
                type.baseURL + type.path,
                method: type.httpMethod,
                parameters: params,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .responseJSON { data in
                switch data.result {
                case .success(_):
                    let decoder = JSONDecoder()
                    if let jsonData = data.data {
                        let result = try! decoder.decode(T.self, from: jsonData)
                        onSuccess(result)
                    }
                    break
                case .failure(let error):
                    onFailure(error)
                    break
                }
            }
    }
}

protocol EndPointType {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
}
