//
//  ReviewResponse.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 27.07.2021..
//

import Foundation

struct Review: Codable {
    let id: String
    let comment: String
    let rating: Int
    let showId: Int
    let user: User

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case showId = "show_id"
        case comment
        case rating
        case user
    }
}

struct ReviewResponse: Codable {
    let reviews: [Review]
    let meta: Meta
}

struct SingleReviewResponse: Codable {
    let review: Review
}
