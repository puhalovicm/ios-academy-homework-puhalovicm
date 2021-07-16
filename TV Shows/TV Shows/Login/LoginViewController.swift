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
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeButton: UIButton!
    
    private var username: String = ""
    private var password: String = ""
    private var rememberMeSelected: Bool = false
    private var showPassword: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButtons()
        setupProgressHUD()
        setupButtons()
        setupActivityIndicator()
        setupUsernameTextField()
        setupPasswordTextField()
    }
    
    @IBAction func onShowPasswordClicked(_ showPasswordButton: UIButton!) {
        showPassword = !showPassword
        if showPassword {
            self.passwordTextField.isSecureTextEntry = false
            setShowPasswordButtonImage(showPasswordButton: showPasswordButton)
        } else {
            self.passwordTextField.isSecureTextEntry = true
            setDoNotShowPasswordButtonImage(showPasswordButton: showPasswordButton)
        }
    }
    
    @IBAction func onButtonClicked(_ sender: Any) {
        printMessage()
        switchActivityIndicatorAnimating()
        print(String(format: "Username: %1$@\nPassword: %2$@\nRememberMe: %3$@", username, password, rememberMeSelected ? "YES" : "NO"))
    }
    
    
    @IBAction func onRememberMeSelected(_ sender: Any) {
        rememberMeSelected = !rememberMeSelected
        if rememberMeSelected {
            setRememberMeSelectedImage()
        } else {
            setRememberMeUnselectedImage()
        }
    }
    
    @IBAction func onUsernameChanged(_ sender: Any) {
        username = self.usernameTextField.text ?? ""
        updateButtons()
    }
    
    @IBAction func onPasswordChanged(_ sender: Any) {
        password = self.passwordTextField.text ?? ""
        updateButtons()
    }
}

private extension LoginViewController {
    
    func setupPasswordTextField() {
        setBottomLine(textField: self.passwordTextField)
        setLeftPaddingView(textField: self.passwordTextField)
        self.passwordTextField.rightView = createShowPasswordButton()
        self.passwordTextField.rightViewMode = .always
        
    }
    
    func setupUsernameTextField() {
        setBottomLine(textField: self.usernameTextField)
        setLeftPaddingView(textField: self.usernameTextField)
        setRightPaddingView(textField: self.usernameTextField)
    }
    
    func setBottomLine(textField: UITextField, height: CGFloat = 1.0) {
        textField.layer.masksToBounds = true
        let usernameBottomLine = CALayer()
        usernameBottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - height, width: textField.frame.width, height: height)
        usernameBottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(usernameBottomLine)
    }
    
    func setLeftPaddingView(textField: UITextField, padding: CGFloat = 10) {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
    }
    
    func setRightPaddingView(textField: UITextField, padding: CGFloat = 10) {
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
    }
    
    func createShowPasswordButton() -> UIButton {
        let showPasswordButton = UIButton(type: .custom)
        showPasswordButton.setImage(UIImage(named: "ic-invisible"), for: .normal)
        showPasswordButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        showPasswordButton.addTarget(self, action: #selector(self.onShowPasswordClicked), for: .touchUpInside)
        return showPasswordButton
    }
    
    func updateButtons() {
        setButtonsEnabled(isEnabled: checkLoginParams())
    }
    
    func setButtonsEnabled(isEnabled: Bool) {
        button.isEnabled = isEnabled
        registerButton.isEnabled = isEnabled
        
        if (isEnabled) {
            button.backgroundColor = UIColor.white
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
    
    func checkLoginParams() -> Bool {
        return !username.isEmpty && !password.isEmpty
    }
    
    func printMessage() {
        print("Button clicked!")
    }
    
    func setupButtons() {
        button.layer.cornerRadius = 25
        
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        button.setTitleColor(UIColor(named: "Purple"), for: .normal)

        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        registerButton.setTitleColor(.white, for: .normal)
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
    
    func switchActivityIndicatorAnimating() {
        if (activityIndicator.isAnimating) {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    func setShowPasswordButtonImage(showPasswordButton: UIButton) {
        if let image = UIImage(named: "ic-visible") {
            showPasswordButton.setImage(image, for: .normal)
        }
    }
    
    func setDoNotShowPasswordButtonImage(showPasswordButton: UIButton) {
        if let image = UIImage(named: "ic-invisible") {
            showPasswordButton.setImage(image, for: .normal)
        }
    }
    
    func setRememberMeSelectedImage() {
        if let image = UIImage(named: "ic-checkbox-selected") {
            self.rememberMeButton.setImage(image, for: .normal)
        }
    }

    func setRememberMeUnselectedImage() {
        if let image = UIImage(named: "ic-checkbox-unselected") {
            self.rememberMeButton.setImage(image, for: .normal)
        }
    }
}
