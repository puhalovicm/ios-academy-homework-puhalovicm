//
//  LoginController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 17.07.2021..
//

import Foundation
import Alamofire

class LoginService {

    static let sharedInstance = LoginService()

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

    func fetchUserInfo(headers: [String: String], onResult: @escaping (Result<(UserResponse, [String: String]?), Error>) -> Void) {
        let type = UserInfoEndPointType(headers: headers)
        networkManager.call(type: type, onResult: onResult)
    }

    func storeImage(image: UIImage, headers: [String: String], onResult: @escaping (Result<(UserResponse, [String: String]?), Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }

        let requestData = MultipartFormData()
        requestData.append(
            imageData,
            withName: "image",
            fileName: "image.jpg",
            mimeType: "image/jpg"
        )

        let type = ImageUploadEndPointType(headers: headers)

        networkManager.callWithMultipartFormData(type: type, multipartFormData: requestData, onResult: onResult)
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

class UserInfoEndPointType : EndPointType {
    var headers: [String : String]

    init(headers: [String: String]) {
        self.headers = headers
    }

    var baseURL = Constants.baseUrl
    var path = "/users/me"
    var httpMethod = HTTPMethod.get
}

class ImageUploadEndPointType : EndPointType {
    var headers: [String : String]

    init(headers: [String: String]) {
        self.headers = headers
    }

    var baseURL = Constants.baseUrl
    var path = "/users"
    var httpMethod = HTTPMethod.put
}
