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
        UITabBar.appearance().tintColor = UIColor(named: "red")
  
       
        viewControllers = [createNewRunVC(), createProfileVC()]
        self.tabBar.unselectedItemTintColor = UIColor.secondaryLabel
      
    }
    
    private func createNewRunVC() -> UIViewController {
        let newRunVC = NewRunViewController()
        newRunVC.title = "Бег"
        newRunVC.tabBarItem.image = UIImage(systemName: "figure.run")
        return newRunVC
    }
    
    private func createProfileVC() -> UIViewController {
        let profileVC = ProfileViewController()
        profileVC.title = "Профиль"
        profileVC.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        return profileVC
    }
    
  
    
}


