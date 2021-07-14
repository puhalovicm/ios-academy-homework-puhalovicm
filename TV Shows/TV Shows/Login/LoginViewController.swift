//
//  LoginViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 10.07.2021..
//

import Foundation
import UIKit
import SVProgressHUD

final class LoginViewController: UIViewController {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var numberOfTaps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProgressHUD()
        setBackgroundColor()
        renderNumberOfTaps()
        setupButton()
        setupActivityIndicator()
    }
    
    @IBAction func onButtonClicked(_ sender: Any) {
        numberOfTaps += 1
        renderNumberOfTaps()
        
        printMessage()
        switchActivityIndicatorAnimating()
    }
}

private extension LoginViewController {
    
    func printMessage() {
        print("Button clicked!")
    }
    
    func setBackgroundColor() {
        let backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        view.backgroundColor = backgroundColor
    }
    
    func setupButton() {
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named:"add"), for: .normal)
    }
    
    func setupActivityIndicator() {
        activityIndicator.color = .systemTeal
        activityIndicator.startAnimating()
        stopAnimatingActivityIndicatorAfterDelay(delay: 3.0)
    }
    
    func setupProgressHUD() {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            SVProgressHUD.dismiss()
        }
    }
    
    func stopAnimatingActivityIndicatorAfterDelay(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func renderNumberOfTaps() {
        label.text = String(numberOfTaps)
    }
    
    func switchActivityIndicatorAnimating() {
        if (activityIndicator.isAnimating) {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}
