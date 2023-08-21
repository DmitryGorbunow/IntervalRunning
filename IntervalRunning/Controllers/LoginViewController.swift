//
//  LoginViewController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/30/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("LogIn", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func loginButtonTapped() {
        let tabBarVC = UITabBarController()
        
        let vc1 = NewRunViewController()
        let vc2 = ProfileViewController()
        
        vc1.title = "Бег"
        vc2.title = "Профиль"
        
        vc1.tabBarItem.image = UIImage(systemName: "figure.run")
        vc2.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        
        tabBarVC.setViewControllers([vc1, vc2], animated: false)
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }
}
