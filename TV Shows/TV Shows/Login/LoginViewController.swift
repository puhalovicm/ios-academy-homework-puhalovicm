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

    static let defaultMessageDuration: Double = 0.5

    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!

    private var email: String = ""
    private var password: String = ""
    private var rememberMeSelected: Bool = false
    private var showPassword: Bool = false
    
    private var loginService: LoginService = LoginService.sharedInstance

    private var user: UserResponse? = nil

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        setButtonsEnabled(isEnabled: isInputValid)
        setupEmailTextField()
        setupPasswordTextField()
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        hideKeyboardWhenTappedAround()

        #if DEBUG
        loginButton.isEnabled = true
        registerButton.isEnabled = true
        email = "mateo.puhalovic@test.com"
        password = "password1"
        #endif

        navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

private extension LoginViewController {

    func pulsateTextfields() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        animation.delegate = self
        passwordTextField.layer.add(animation, forKey: "shake")
    }

    func delayedAction(duration: Double = defaultMessageDuration, action: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            action()
        }
    }

    @objc func onOrientationChange() {
        setupEmailTextField()
        setupPasswordTextField()
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
        
        let firstResponder: UITextField
        
        if emailTextField.isFirstResponder {
            firstResponder = emailTextField
        } else {
            firstResponder = passwordTextField
        }
        
        if let frame = firstResponder.superview?.convert(firstResponder.frame, to: nil) {
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
    
    @IBAction func onEmailEnterClicked(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func onPasswordEnterClicked(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
        else {
            showInputErrorMessage()
            return
        }

        attemptLogin()
        view.endEditing(true)
    }

    @IBAction func onShowPasswordClicked(_ showPasswordButton: UIButton!) {
        showPassword = !showPassword
        passwordTextField.isSecureTextEntry = !showPassword
        setShowPassword(showPasswordButton: showPasswordButton, shouldShow: showPassword)
    }
    
    @IBAction func onLoginButtonClicked(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
        else {
            showInputErrorMessage()
            return
        }

        attemptLogin()
        view.endEditing(true)
    }
    
    @IBAction func onRegisterButtonClicked(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
        else {
            showInputErrorMessage()
            return
        }

        attemptRegister()
        view.endEditing(true)
    }

    @IBAction func onRememberMeSelected(_ sender: Any) {
        rememberMeSelected = !rememberMeSelected
        setRememberMe(isSelected: rememberMeSelected)
    }

    @IBAction func onEmailChanged(_ sender: Any) {
        email = emailTextField.text ?? ""
        setButtonsEnabled(isEnabled: isInputValid)
    }

    @IBAction func onPasswordChanged(_ sender: Any) {
        password = passwordTextField.text ?? ""
        setButtonsEnabled(isEnabled: isInputValid)
    }
    
    func attemptLogin() {
        SVProgressHUD.show()
        
        loginService.login(
            email: email,
            password: password
        ) { [weak self] result in
            SVProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success (let user):
                self.user = user.0

                if let headers = user.1 {
                    NetworkManager.sharedInstance.authInfo = AuthInfo(headers: headers)

                    if self.rememberMeSelected {
                        KeychainService.sharedInstance.saveAuthInfo(authInfo: AuthInfo(headers: headers))
                    }
                }
                
                self.showSuccessMessage()
                self.showHomeViewController()
            case .failure:
                self.pulsateTextfields()
            }
        }
    }
    
    func attemptRegister() {
        SVProgressHUD.show()
        
        loginService.register(
            email: email,
            password: password
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let user):
                self.user = user.0

                if let headers = user.1 {
                    NetworkManager.sharedInstance.authInfo = AuthInfo(headers: headers)

                    if self.rememberMeSelected {
                        KeychainService.sharedInstance.saveAuthInfo(authInfo: AuthInfo(headers: headers))
                    }
                }

                self.showSuccessMessage()
                self.showHomeViewController()
            case .failure:
                self.showErrorAlert()
            }
        }
    }

    func showInputErrorMessage() {
        SVProgressHUD.dismiss()
        showErrorAlert(message: "Please enter username and password.")
    }

    func showNetworkErrorMessage() {
        SVProgressHUD.dismiss()
        showErrorAlert(message: "Please check whether you entered correct username and password.")
    }

    func showSuccessMessage() {
        SVProgressHUD.showSuccess(withStatus: "Success")
        delayedAction {
            SVProgressHUD.dismiss()
        }
    }

    func showHomeViewController() {
        let vc = UIStoryboard.init(name: "Home", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

        vc.userResponse = user

        navigationController?.pushViewController(vc, animated: true)
    }

    func setupPasswordTextField() {
        setBottomLine(textField: passwordTextField)
        setLeftPaddingView(textField: passwordTextField)
        passwordTextField.rightView = createShowPasswordButton()
        passwordTextField.rightViewMode = .always

        #if DEBUG
        passwordTextField.text = "password1"
        #endif
    }

    func setupEmailTextField() {
        setBottomLine(textField: emailTextField)
        setLeftPaddingView(textField: emailTextField)
        setRightPaddingView(textField: emailTextField)

        #if DEBUG
        emailTextField.text = "mateo.puhalovic@test.com"
        #endif
    }

    func setBottomLine(textField: UITextField, height: CGFloat = 1.0) {
        textField.layer.masksToBounds = true
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - height, width: view.frame.width - 40, height: height)
        bottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
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
        !email.isEmpty && !password.isEmpty
    }
    
    func setupButtons() {
        loginButton.layer.cornerRadius = 25

        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.setTitleColor(UIColor(named: "Purple"), for: .normal)

        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        registerButton.setTitleColor(.white, for: .normal)
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

extension LoginViewController: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.showNetworkErrorMessage()
    }
}
