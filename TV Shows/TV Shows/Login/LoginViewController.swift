//
//  LoginViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 10.07.2021..
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var numberOfTaps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBgColor()
        renderNumberOfTaps()
        initButton()
        initActivityIndicator()
    }
    
    @IBAction func onButtonClicked(_ sender: Any) {
        numberOfTaps += 1
        renderNumberOfTaps()
        
        printMessage()
        switchActivityIndicatorAnimating()
    }

    private func printMessage() {
        print("Button clicked!")
    }
    
    private func setBgColor() {
        let bgColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        view.backgroundColor = bgColor
    }
    
    private func initButton() {
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named:"add"), for: .normal)
    }
    
    private func initActivityIndicator() {
        activityIndicator.color = .systemTeal
        activityIndicator.startAnimating()
        stopAnimatingActivityIndicatorAfterDelay(delay: 3.0)
    }
    
    private func stopAnimatingActivityIndicatorAfterDelay(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func renderNumberOfTaps() {
        label.text = String(numberOfTaps)
    }
    
    private func switchActivityIndicatorAnimating() {
        if (activityIndicator.isAnimating) {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}

