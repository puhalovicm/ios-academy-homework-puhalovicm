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
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var email: String = ""
    private var password: String = ""
    private var rememberMeSelected: Bool = false
    private var showPassword: Bool = false
    
    private var loginManager: LoginManager = LoginManager()

    private var user: UserResponse? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButtons()
        setupButtons()
        setupUsernameTextField()
        setupPasswordTextField()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        scrollView.bounces = false
    }

    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func onOrientationChange() {
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
    
    @IBAction func onLoginButtonClicked(_ sender: Any) {
        SVProgressHUD.show()
        
        loginManager.login(
            email: email,
            password: password,
            onSuccess: { [weak self] user in
                self?.user = user
                SVProgressHUD.showSuccess(withStatus: "Success")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SVProgressHUD.dismiss()
                }
            },
            onFailure: { error in
                SVProgressHUD.showError(withStatus: "Failure")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SVProgressHUD.dismiss()
                }
            }
        )
    }
    
    @IBAction func onRegisterButtonClicked(_ sender: Any) {
        SVProgressHUD.show()

        loginManager.register(
            email: email,
            password: password,
            onSuccess: { [weak self] user in
                self?.user = user
                
                SVProgressHUD.showSuccess(withStatus: "Success")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SVProgressHUD.dismiss()
                }
            },
            onFailure: { error in
                SVProgressHUD.showError(withStatus: "Failure")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SVProgressHUD.dismiss()
                }
            }
        )
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
        email = self.emailTextField.text ?? ""
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
        setBottomLine(textField: self.emailTextField)
        setLeftPaddingView(textField: self.emailTextField)
        setRightPaddingView(textField: self.emailTextField)
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
        loginButton.isEnabled = isEnabled
        registerButton.isEnabled = isEnabled
        
        if (isEnabled) {
            loginButton.backgroundColor = UIColor.white
        } else {
            loginButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
    
    func checkLoginParams() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    func setupButtons() {
        loginButton.layer.cornerRadius = 25
        
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.setTitleColor(UIColor(named: "Purple"), for: .normal)

        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        registerButton.setTitleColor(.white, for: .normal)
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
