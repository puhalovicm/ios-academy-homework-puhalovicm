//
//  LoginController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 17.07.2021..
//

import Foundation
import Alamofire

class LoginManager {

    static let sharedInstance = LoginManager()

    private init() { }

    let networkManager = NetworkManager.sharedInstance

    func login(email: String, password: String, onResult: @escaping (Result<(UserResponse, [String: String]?), Error>) -> Void) {
        let type = LoginEndPointType(email: email, password: password)
        
        networkManager.call(type: type, onResult: onResult)
    }

    func register(email: String, password: String, onResult: @escaping (Result<(UserResponse, [String: String]?), Error>) -> Void) {
        let type = RegisterEndPointType(email: email, password: password)
        
        networkManager.call(type: type, onResult: onResult)
    }
}

class LoginEndPointType : EndPointType {

    let email: String
    let password: String
    var params: [String: String]?

    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.params = [
            "email": email,
            "password": password
        ]
    }

    var baseURL = Constants.baseUrl
    var path = "/users/sign_in"
    var httpMethod = HTTPMethod.post
}

class RegisterEndPointType : EndPointType {

    let email: String
    let password: String
    var params: [String: String]?

    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.params = [
            "email": email,
            "password": password,
            "password_confirmation": password
        ]
    }

    var baseURL = Constants.baseUrl
    var path = "/users"
    var httpMethod = HTTPMethod.post
}
