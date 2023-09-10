//
//  SceneDelegate.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/22/23.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.setupWindow(with: scene)
        self.checkAuthentication()
    }
    
    private func setupWindow(with scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    // verification of user authorization. if there is authorization, the TabBarController is set by the root controller, if not, then SignInViewController is set
    public func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = nav
        } else {
            let vc = TabBarController()
            self.window?.rootViewController = vc
        }
    }
}

