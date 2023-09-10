//
//  ProfileViewController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/30/23.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    var results = [Run]()
    
    private let logOutButton = CustomButton(title: "Выйти", hasBackground: true, fontSize: .big)
    
    private let resultsTableView: UITableView = {
        let tableView = UITableView()
//        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileImage")
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let myRunsLabel: UILabel = {
        let label = UILabel()
        label.text = "Мои пробежки:"
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getUserData()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(ResultsTableViewCell.self, forCellReuseIdentifier: ResultsTableViewCell.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let context = CoreDataStack.context
        
        let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        results = objects
        results.sort(by: { $0.timestamp! > $1.timestamp! })
        
        resultsTableView.reloadData()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Профиль"
//
        
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(myRunsLabel)
        view.addSubview(logOutButton)
        view.addSubview(resultsTableView)
        
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        logOutButton.addTarget(self, action: #selector(didTapLogOut), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            profileImage.heightAnchor.constraint(equalToConstant: 100),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            nameLabel.heightAnchor.constraint(equalToConstant: 40),
            
            myRunsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            myRunsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            myRunsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            myRunsLabel.heightAnchor.constraint(equalToConstant: 25),
            
            logOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            logOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            logOutButton.heightAnchor.constraint(equalToConstant: 50),
            logOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            resultsTableView.topAnchor.constraint(equalTo: myRunsLabel.bottomAnchor, constant: 30),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultsTableView.bottomAnchor.constraint(equalTo: logOutButton.topAnchor, constant: -30)
        ])
    }
    
    // getting the user's name and email from Firebase
    private func getUserData() {
        AuthService.shared.fetchUser { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showFetchingUserError(on: self, with: error)
            }
            
            if let user = user {
                self.nameLabel.text = user.username
            }
        }
    }
    
    @objc private func didTapLogOut() {
        
        // Create Alert
        let dialogMessage = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "Выход", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            AuthService.shared.signOut { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    AlertManager.showLogoutError(on: self, with: error)
                    return
                }
                
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            }
            
        })

        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Отмена", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }

        //Add OK and Cancel button to an Alert object
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)

        // Present alert message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell") as? ResultsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(run: results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RunDetailsViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.run = results[indexPath.row]
        present(vc, animated: true)
    }
}
