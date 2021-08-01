//
//  RatingManager.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 27.07.2021..
//

import Foundation
import Alamofire

class ReviewService {

    static let sharedInstance = ReviewService()

    private init() { }

    let networkManager = NetworkManager.sharedInstance

    func fetchReviews(page: Int = 1, items: Int = 10, showId: String, headers: [String: String], onResult: @escaping (Result<(ReviewResponse, [String: String]?), Error>) -> Void) {
        let type = ReviewEndPointType(page: page, items: items, showId: showId, headers: headers)

        networkManager.call(type: type, onResult: onResult)
    }

    func writeReview(showId: String, rating: Int, comment: String, headers: [String: String], onResult: @escaping (Result<(SingleReviewResponse, [String: String]?), Error>) -> Void) {
        let type = WriteReviewEndPointType(rating: rating, comment: comment, showId: showId, headers: headers)

        networkManager.call(type: type, onResult: onResult)
    }
}

class ReviewEndPointType : EndPointType {

    var path: String
    var headers: [String : String]
    var queryParams: [String : String]

    init(page: Int, items: Int, showId: String, headers: [String: String]) {
        path = "/shows/" + showId + "/reviews"
        self.headers = headers
        self.queryParams = [
            "page": String(page),
            "items": String(items)
        ]
    }

    var baseURL = Constants.baseUrl
    var httpMethod = HTTPMethod.get
}

class WriteReviewEndPointType : EndPointType {

    let rating: Int
    let comment: String
    let showId: String
    var params: [String: String]?
    var headers: [String : String]

    init(rating: Int, comment: String, showId: String, headers: [String: String]) {
        self.rating = rating
        self.comment = comment
        self.showId = showId
        self.params = [
            "rating": String(rating),
            "comment": comment,
            "show_id": showId
        ]
        self.headers = headers
    }

    var baseURL = Constants.baseUrl
    var path = "/reviews"
    var httpMethod = HTTPMethod.post
}
