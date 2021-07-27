//
//  TVShowTableCell.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 21.07.2021..
//

import Foundation
import UIKit
import Kingfisher

final class TVShowTableViewCell: UITableViewCell {

    // MARK: - Private UI

    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImageView.image = nil
        titleLabel.text = nil
    }

}

// MARK: - Configure

extension TVShowTableViewCell {

    func configure(with item: TVShowItem) {
        thumbnailImageView.kf.setImage(
            with: item.image,
            placeholder: UIImage(named: "icImagePlaceholder")
        )

        titleLabel.text = item.name
    }
}

// MARK: - Private

private extension TVShowTableViewCell {

    func setupUI() {
        thumbnailImageView.layer.cornerRadius = 5
        thumbnailImageView.layer.masksToBounds = true
    }
}
