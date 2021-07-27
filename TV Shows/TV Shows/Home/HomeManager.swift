//
//  HomeManager.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 21.07.2021..
//

import Foundation

import Alamofire

class HomeManager {
    
    let networkManager = NetworkManager.sharedInstance
    
    func fetchShows(page: Int = 1, items: Int = 10, headers: [String: String], onResult: @escaping (Result<(ShowResponse, [String: String]?), Error>) -> Void) {
        let type = ShowsEndPointType(page: page, items: items, headers: headers)
        
        networkManager.call(type: type, onResult: onResult)
    }
}

class ShowsEndPointType : EndPointType {
    let page: Int
    let items: Int
    var queryParams: [String: String]
    var headers: [String : String]

    init(page: Int, items: Int, headers: [String: String]) {
        self.page = page
        self.items = items
        self.queryParams = [
            "page": String(page),
            "items": String(items)
        ]
        self.headers = headers
    }

    var baseURL = Constants.baseUrl
    var path = "/shows"
    var httpMethod = HTTPMethod.get
}
