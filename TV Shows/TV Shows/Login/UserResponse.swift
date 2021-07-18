//
//  User.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 16.07.2021..
//

import Foundation

struct User: Codable {
   let email: Optional<String>
   let imageUrl: Optional<String>
   let id: Optional<String>
   
    enum CodingKeys: String, CodingKey {
        case email
        case imageUrl = "image_url"
        case id = "_id"
   }
}

struct UserResponse: Codable {
    let user: User
}
