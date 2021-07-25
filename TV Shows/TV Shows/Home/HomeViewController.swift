//
//  HomeViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 16.07.2021..
//

import Foundation
import UIKit
import SVProgressHUD

final class HomeViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
