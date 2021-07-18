//
//  LoginController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 17.07.2021..
//

import Foundation
import Alamofire

class LoginManager {
    
    let networkManager = NetworkManager()
    
    func login(email: String, password: String, onSuccess: @escaping (UserResponse) -> Void, onFailure: @escaping (Error) -> Void) {
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        let type = LoginEndPointType()
        
        networkManager.call(type: type, params: parameters, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func register(email: String, password: String, onSuccess: @escaping (UserResponse) -> Void, onFailure: @escaping (Error) -> Void) {
        let parameters: [String: String] = [
            "email": email,
            "password": password,
            "password_confirmation": password
        ]
        
        let type = RegisterEndPointType()
        
        networkManager.call(type: type, params: parameters, onSuccess: onSuccess, onFailure: onFailure)
    }
}

class LoginEndPointType : EndPointType {
    var baseURL = "https://tv-shows.infinum.academy"
    var path = "/users/sign_in"
    var httpMethod = HTTPMethod.post
}

class RegisterEndPointType : EndPointType {
    var baseURL = "https://tv-shows.infinum.academy"
    var path = "/users"
    var httpMethod = HTTPMethod.post
}
