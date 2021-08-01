//
//  TVShowItem.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 21.07.2021..
//

import Foundation
import UIKit

struct TVShowItem {
    let showId: String
    let name: String
    let imageUrl: URL?
    let showTitle: String
    let showDescription: String?
    let noOfReviews: Int
    let averageRating: Double
}
