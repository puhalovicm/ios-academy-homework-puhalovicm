//
//  ShowDetailsTopTableViewCell.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 27.07.2021..
//

import Foundation
import UIKit

final class ShowDetailsTopTableViewCell: UITableViewCell {

    // MARK: - Private UI

    @IBOutlet private weak var showImage: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var ratingOverviewLabel: UILabel!
    @IBOutlet private weak var overviewRatingView: RatingView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        showImage.image = nil
        descriptionLabel.text = nil
        descriptionLabel.numberOfLines = 0
        ratingOverviewLabel.text = nil
        overviewRatingView.rating = 0
        overviewRatingView.configure(withStyle: .large)
        overviewRatingView.isEnabled = false
    }

}

// MARK: - Configure

extension ShowDetailsTopTableViewCell {

    func configure(with item: Show) {
        showImage.kf.setImage(
            with: URL(string: item.imageUrl ?? ""),
            placeholder: UIImage(named: "icImagePlaceholder")
        )
        descriptionLabel.text = item.description
        overviewRatingView.setRoundedRating(Double(item.averageRating ?? 0))

        if
            let noOfReviews = item.noOfReviews,
            noOfReviews > 1,
            let averageRating = item.averageRating
        {
            showReviewOverviewLabel(noOfReviews: noOfReviews, averageRating: averageRating)
        } else {
            showNoReviewsLabel()
        }
    }
}

// MARK: - Private

private extension ShowDetailsTopTableViewCell {

    func setupUI() {
        showImage.layer.cornerRadius = 5
        showImage.layer.masksToBounds = true
        descriptionLabel.numberOfLines = 0
        selectionStyle = .none
    }

    func showReviewOverviewLabel(noOfReviews: Int, averageRating: Double) {
        ratingOverviewLabel.textAlignment = .left
        ratingOverviewLabel.text = (String(noOfReviews) + " reviews, " + String(averageRating) + " average").uppercased()
    }

    func showNoReviewsLabel() {
        ratingOverviewLabel.textAlignment = .center
        ratingOverviewLabel.text = "No reviews yet."
    }
}
