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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    var delegate: WriteReviewViewControllerDelegate? = nil

    var showId: String? = nil
    var authInfo: AuthInfo? = nil

    @IBOutlet private weak var ratingView: RatingView!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var submitReviewButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!

    private var rating: Int? = nil
    private var comment: String = ""
    private let reviewManager: ReviewManager = ReviewManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupSubmitButton()
        setupCommentTextView()
        hideKeyboardWhenTappedAround()

        ratingView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        commentTextView.text = "Enter your comment here..."
        commentTextView.textColor = UIColor(named: "BlackMediumOpacity")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        if let frame = commentTextView.superview?.convert(commentTextView.frame, to: nil) {
            let frameBottom = frame.origin.y + frame.size.height
            let keyboardTop = keyboardSize.origin.y

            let diff = keyboardTop - frameBottom - 20

            if diff < 0 {
                scrollView.setContentOffset(CGPoint(x: 0.0, y: -diff), animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }

    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
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

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(named: "BlackMediumOpacity") {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your comment here..."
            textView.textColor = UIColor(named: "BlackMediumOpacity")
        }
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

        navigationController?.navigationBar.barTintColor = UIColor(named: "Gray")
        navigationController?.navigationBar.tintColor = UIColor(named: "Purple")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
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
