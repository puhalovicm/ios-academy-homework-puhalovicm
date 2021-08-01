//
//  ReviewViewCell.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 28.07.2021..
//

import Foundation
import UIKit

final class ReviewViewCell: UITableViewCell {

    // MARK: - Private UI

    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var ratingView: RatingView!
    @IBOutlet private weak var reviewLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        profileImage.image = nil
        emailLabel.text = nil
        reviewLabel.text = nil
        ratingView.rating = 0
        ratingView.configure(withStyle: .small)
        ratingView.isEnabled = false
    }

}

// MARK: - Configure

extension ReviewViewCell {

    func configure(with item: Review) {
        emailLabel.text = item.user.email

        profileImage.kf.setImage(
            with: URL(string: item.user.imageUrl ?? ""),
            placeholder: UIImage(named: "ic-profile-placeholder")
        )

        reviewLabel.text = item.comment
        
        ratingView.setRoundedRating(Double(item.rating))
    }
}

// MARK: - Private

private extension ReviewViewCell {

    func setupUI() {
        profileImage.layer.cornerRadius = 25
        profileImage.layer.masksToBounds = true
        selectionStyle = .none
        reviewLabel.numberOfLines = 0
    }
}
