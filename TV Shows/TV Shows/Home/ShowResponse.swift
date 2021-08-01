//
//  ShowResponse.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 21.07.2021..
//

import Foundation

struct Show: Codable {
    let id: String
    let averageRating: Double
    let description: String?
    let imageUrl: URL?
    let noOfReviews: Int
    let title: String
    
     enum CodingKeys: String, CodingKey {
        case id = "id"
        case averageRating = "average_rating"
        case imageUrl = "image_url"
        case noOfReviews = "no_of_reviews"
        case description
        case title
    }
}

struct Meta: Codable {
    let pagination: Pagination
}

struct Pagination: Codable {
    let count: Int
    let page: Int
    let items: Int
    let pages: Int
}

struct ShowResponse: Codable {
    let shows: [Show]
    let meta: Meta
}
