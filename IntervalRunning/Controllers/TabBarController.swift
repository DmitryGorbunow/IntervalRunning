//
//  TabBarController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/30/23.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = UIColor(named: "yellow")
  
       
        viewControllers = [createNewRunVC(), createProfileVC()]
        self.tabBar.unselectedItemTintColor = UIColor(named: "dark")
      
    }
    
    private func createHomeVC() -> UINavigationController {
        let homeVC = HomeViewController()
        homeVC.title = "Главная"
        homeVC.tabBarItem.image = UIImage(systemName: "house.circle")
        return UINavigationController(rootViewController: homeVC)
    }
    
    private func createNewRunVC() -> UINavigationController {
        let newRunVC = NewRunViewController()
        newRunVC.title = "Бег"
        newRunVC.tabBarItem.image = UIImage(systemName: "figure.run")
        return UINavigationController(rootViewController: newRunVC)
    }
    
    private func createProfileVC() -> UINavigationController {
        let profileVC = ProfileViewController()
        profileVC.title = "Профиль"
        profileVC.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        return UINavigationController(rootViewController: profileVC)
    }
    
  
    
}


