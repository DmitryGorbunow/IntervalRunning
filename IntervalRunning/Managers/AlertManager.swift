//
//  AlertManager.swift
//  Interval Running
//
//  Created by Dmitry Gorbunow on 8/29/23.
//

import UIKit

class AlertManager {
    
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
}

// MARK: - Show Validation Alerts
extension AlertManager {
    
    public static func showInvalidEmailAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Некорректная почта", message: "Проверьте корректность ввода почты")
    }
    
    public static func showInvalidPasswordAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Некорректный пароль", message: "Проверьте корректность ввода пароля. Пароль должен содержать заглавные буквы, числа и специальные символы")
    }
    
    public static func showInvalidUsernameAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Некорректное имя", message: "Проверьте корректность ввода имени")
    }
}


// MARK: - Registration Errors
extension AlertManager {
    
    public static func showRegistrationErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Ошибка регистрации", message: nil)
    }
    
    public static func showRegistrationErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Ошибка регистрации", message: "\(error.localizedDescription)")
    }
}


// MARK: - Log In Errors
extension AlertManager {
    
    public static func showSignInErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Ошибка входа", message: nil)
    }
    
    public static func showSignInErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Ошибка входа", message: "\(error.localizedDescription)")
    }
}


// MARK: - Logout Errors
extension AlertManager {
    
    public static func showLogoutError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "При попытке выхода призошла ошибка", message: "\(error.localizedDescription)")
    }
}


// MARK: - Forgot Password
extension AlertManager {

    public static func showPasswordResetSent(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Пароль сброшен", message: nil)
    }
    
    public static func showErrorSendingPasswordReset(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Ошибка сброса пароля", message: "\(error.localizedDescription)")
    }
}


// MARK: - Fetching User Errors
extension AlertManager {
    
    public static func showFetchingUserError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Ошибка получения данных пользователя", message: "\(error.localizedDescription)")
    }
    
    public static func showUnknownFetchingUserError(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Ошибка получения данных пользователя", message: nil)
    }
}
