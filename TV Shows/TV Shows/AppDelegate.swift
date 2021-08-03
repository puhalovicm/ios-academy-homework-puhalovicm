//
//  AppDelegate.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 08.07.2021..
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Create navigation controller in which we will embedd our starting view controller

        let navigationController = UINavigationController()
        let authInfo: AuthInfo? = KeychainService.sharedInstance.fetchAuthInfo()

        // Check if user picked remember me
        if authInfo != nil {
            let storyboard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            NetworkManager.sharedInstance.authInfo = authInfo
            navigationController.viewControllers = [homeViewController]
        } else {
            let storyboard = UIStoryboard.init(name: "Login", bundle: Bundle.main)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            navigationController.viewControllers = [loginViewController]
        }
        // Set the navigation controller as starting point of the app
        window?.rootViewController = navigationController
        
        return true
    }
}

