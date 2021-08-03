//
//  ProfileViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 01.08.2021..
//

import UIKit
import SVProgressHUD

class ProfileViewController: UIViewController {

    private let loginService: LoginService = LoginService.sharedInstance

    let imagePicker = UIImagePickerController()

    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var activityIndicatorProfile: UIActivityIndicatorView!

    override func viewDidLoad() {
        SVProgressHUD.show()
        setupNavigationItem()

        profileImage.layer.cornerRadius = 50
        profileImage.layer.masksToBounds = true
        logoutButton.layer.cornerRadius = 25
        logoutButton.layer.masksToBounds = true

        profileImage.image = UIImage(named: "icProfilePlaceholder")

        fetchUserInfo()
        activityIndicatorProfile.isHidden = true
        activityIndicatorProfile.stopAnimating()

        imagePicker.delegate = self
    }

    func fetchUserInfo() {
        guard let headers = NetworkManager.sharedInstance.authInfo?.headers else { return }

        loginService.fetchUserInfo(
            headers: headers
        ) { [weak self] result in
            SVProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success (let user):
                self.emailLabel.text = user.0.user.email
                self.profileImage.kf.setImage(
                    with: user.0.user.imageUrl,
                    placeholder: UIImage(named: "icImagePlaceholder")
                )
            case .failure (let error):
                print(error.localizedDescription)
                self.showNetworkErrorMessage()
            }
        }
    }

    func showNetworkErrorMessage() {
        SVProgressHUD.dismiss()
        showErrorAlert(
            message: "Error occured while fetching account info.",
            okAction: {
                self.didSelectClose()
            }
        )
    }

    func showImageUploadErrorMessage() {
        SVProgressHUD.dismiss()
        showErrorAlert(
            message: "Error occured while uploading image. Please, try again."
        )
    }

    func setupNavigationItem() {
        navigationItem.title = "MyAccount"
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

    @objc private func didSelectClose() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func logoutUser(_ sender: Any) {
        dismiss(animated: true, completion: {
            KeychainService.sharedInstance.removeAuthInfo()
            NetworkManager.sharedInstance.authInfo = nil
            NotificationCenter.default.post(name: .didLogout, object: nil)
        })
    }

    @IBAction func changePfoilePhoto(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if
            let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let headers = NetworkManager.sharedInstance.authInfo?.headers
        {
            self.profileImage.alpha = 0.1
            activityIndicatorProfile.isHidden = false
            activityIndicatorProfile.startAnimating()

            loginService.storeImage(image: pickedImage, headers: headers) { [weak self] result in
                guard let self = self else { return }
                self.profileImage.alpha = 1.0
                self.activityIndicatorProfile.isHidden = true
                self.activityIndicatorProfile.stopAnimating()

                switch result {
                case .success (let user):
                    self.profileImage.kf.setImage(
                        with: user.0.user.imageUrl,
                        placeholder: UIImage(named: "icImagePlaceholder")
                    )
                case .failure (let error):
                    print(error.localizedDescription)
                    self.showImageUploadErrorMessage()
                }
            }
        }

        dismiss(animated: true, completion: nil)
    }
}
