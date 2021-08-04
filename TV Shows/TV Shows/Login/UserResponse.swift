//
//  User.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 16.07.2021..
//

import Foundation

struct User: Codable {
   let email: String
   let imageUrl: URL?
   let id: String
   
    enum CodingKeys: String, CodingKey {
        case email
        case imageUrl = "image_url"
        case id
   }
}

struct UserResponse: Codable {
    let user: User
}
