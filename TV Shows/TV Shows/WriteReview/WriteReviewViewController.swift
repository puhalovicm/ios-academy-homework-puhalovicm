//
//  ReviewWriteViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 30.07.2021..
//

import Foundation
import UIKit
import SVProgressHUD

protocol WriteReviewViewControllerDelegate: AnyObject {
    func onSuccessfulRatingSubmit()
}

class WriteReviewViewController: UIViewController {

    var delegate: WriteReviewViewControllerDelegate? = nil

    var showId: String? = nil
    var authInfo: AuthInfo? = nil

    @IBOutlet private weak var ratingView: RatingView!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var submitReviewButton: UIButton!

    private var rating: Int? = nil
    private var comment: String = ""
    private let reviewManager: ReviewManager = ReviewManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupSubmitButton()
        setupCommentTextView()

        ratingView.delegate = self
    }

    @objc private func didSelectClose() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func writeReview(_ sender: Any) {
        guard
            let showId = showId,
            let authInfo = authInfo,
            let rating = rating,
            !comment.isEmpty
        else {
            showInputErrorMessage()
            return
        }

        submitReview(showId: showId, authInfo: authInfo, rating: rating, comment: comment)
        view.endEditing(true)
    }
}

extension WriteReviewViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        self.comment = textView.text
        setSubmitButtonEnabled(isEnabled: isInputValid)
    }
}

private extension WriteReviewViewController {

    func setupSubmitButton() {
        submitReviewButton.layer.cornerRadius = 25
        submitReviewButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        submitReviewButton.setTitleColor(UIColor.white, for: .normal)
        setSubmitButtonEnabled(isEnabled: false)
    }

    func setupNavigationItem() {
        navigationItem.title = "Write a Review"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(didSelectClose)
        )
    }

    func setupCommentTextView() {
        commentTextView.layer.cornerRadius = 10
        commentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        commentTextView.delegate = self
    }

    func submitReview(showId: String, authInfo: AuthInfo, rating: Int, comment: String) {
        SVProgressHUD.show()

        reviewManager.writeReview(showId: showId, rating: rating, comment: comment, headers: authInfo.headers) { [weak self] result in
            switch result {
            case .success:
                SVProgressHUD.dismiss()
                self?.delegate?.onSuccessfulRatingSubmit()
                self?.dismiss(animated: true, completion: nil)
            case .failure:
                self?.showErrorAlert(message: "Something went wrong.")
            }
        }

    }

    func showInputErrorMessage() {
        SVProgressHUD.dismiss()
        showErrorAlert(message: "Please enter username and password.")
    }

    func setSubmitButtonEnabled(isEnabled: Bool) {
        submitReviewButton.isEnabled = isEnabled
        if isEnabled {
            submitReviewButton.backgroundColor = UIColor(named: "Purple")
        } else {
            submitReviewButton.backgroundColor = UIColor(named: "Purple")?.withAlphaComponent(0.3)
        }
    }

    var isInputValid: Bool {
        rating != nil && !comment.isEmpty
    }
}

extension WriteReviewViewController: RatingViewDelegate {

    func didChangeRating(_ rating: Int) {
        self.rating = rating
        setSubmitButtonEnabled(isEnabled: isInputValid)
    }
}
