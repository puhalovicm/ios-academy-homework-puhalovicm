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
    
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var rememberMeButton: UIButton!
    
    private var username: String = ""
    private var password: String = ""
    private var rememberMeSelected: Bool = false
    private var showPassword: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setButtonsEnabled(isEnabled: isInputValid)
        setupProgressHUD()
        setupButtons()
        setupUsernameTextField()
        setupPasswordTextField()
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

private extension LoginViewController {

    @objc func onOrientationChange() {
        setupUsernameTextField()
        setupPasswordTextField()
    }

    @IBAction func onShowPasswordClicked(_ showPasswordButton: UIButton!) {
        showPassword = !showPassword
        passwordTextField.isSecureTextEntry = !showPassword
        setShowPassword(showPasswordButton: showPasswordButton, shouldShow: showPassword)
    }

    @IBAction func onButtonClicked(_ sender: Any) {
        printMessage()
        print(String(format: "Username: %1$@\nPassword: %2$@\nRememberMe: %3$@", username, password, rememberMeSelected ? "YES" : "NO"))
    }

    @IBAction func onRememberMeSelected(_ sender: Any) {
        rememberMeSelected = !rememberMeSelected
        setRememberMe(isSelected: rememberMeSelected)
    }

    @IBAction func onUsernameChanged(_ sender: Any) {
        username = usernameTextField.text ?? ""
        setButtonsEnabled(isEnabled: isInputValid)
    }

    @IBAction func onPasswordChanged(_ sender: Any) {
        password = passwordTextField.text ?? ""
        setButtonsEnabled(isEnabled: isInputValid)
    }
    
    func setupPasswordTextField() {
        setBottomLine(textField: passwordTextField)
        setLeftPaddingView(textField: passwordTextField)
        passwordTextField.rightView = createShowPasswordButton()
        passwordTextField.rightViewMode = .always
    }
    
    func setupUsernameTextField() {
        setBottomLine(textField: usernameTextField)
        setLeftPaddingView(textField: usernameTextField)
        setRightPaddingView(textField: usernameTextField)
    }
    
    func setBottomLine(textField: UITextField, height: CGFloat = 1.0) {
        textField.layer.masksToBounds = true
        let usernameBottomLine = CALayer()
        usernameBottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - height, width: view.frame.width - 40, height: height)
        usernameBottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = .none
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
        showPasswordButton.addTarget(self, action: #selector(onShowPasswordClicked), for: .touchUpInside)
        return showPasswordButton
    }
    
    func setButtonsEnabled(isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
        registerButton.isEnabled = isEnabled
        
        if isEnabled {
            loginButton.backgroundColor = .white
        } else {
            loginButton.backgroundColor = .white.withAlphaComponent(0.3)
        }
    }
    
    var isInputValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    func printMessage() {
        print("Button clicked!")
    }
    
    func setupButtons() {
        loginButton.layer.cornerRadius = 25
        
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.setTitleColor(UIColor(named: "Purple"), for: .normal)

        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        registerButton.setTitleColor(.white, for: .normal)
    }
    
    func setupProgressHUD() {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            SVProgressHUD.dismiss()
        }
    }

    func setShowPassword(showPasswordButton: UIButton, shouldShow: Bool) {
        let imageName = shouldShow ? "ic-visible" : "ic-invisible"
        guard let image = UIImage(named: imageName) else { return }
        showPasswordButton.setImage(image, for: .normal)
    }

    func setRememberMe(isSelected: Bool) {
        let imageName = isSelected ? "ic-checkbox-selected" : "ic-checkbox-unselected"
        guard let image = UIImage(named: imageName) else { return }
        rememberMeButton.setImage(image, for: .normal)
    }
}
