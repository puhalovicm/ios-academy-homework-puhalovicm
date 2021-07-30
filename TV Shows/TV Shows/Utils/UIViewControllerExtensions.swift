//
//  UIViewControllerExtensions.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 30.07.2021..
//

import Foundation
import UIKit

extension UIViewController {

    func showErrorAlert(
        title: String = "Error occurred",
        message: String = "Error occurred! Please try again later."
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default,
                handler: { _ in
                    // NO - OP
                }
            )
        )

        self.present(alert, animated: true, completion: nil)
    }
}
