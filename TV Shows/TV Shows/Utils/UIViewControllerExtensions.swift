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
        message: String = "Error occurred! Please try again later.",
        okAction: @escaping () -> Void = {}
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
                    okAction()
                }
            )
        )

        self.present(alert, animated: true, completion: nil)
    }

    func setupStatusBar() {
        if #available(iOS 13, *)
        {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor(named: "Gray")
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            let statusBar: UIView? = UIApplication.shared.value(forKey: "statusBar") as? UIView

            guard let statusBarView = statusBar else {
                return
            }

            if statusBarView.responds(to:#selector(setter: UIView.backgroundColor)) {
                statusBarView.backgroundColor = UIColor(named: "Gray")
            }
        }
    }
}
