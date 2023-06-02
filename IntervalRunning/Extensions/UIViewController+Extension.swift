//
//  UIViewController+Extension.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/22/23.
//

import UIKit
 
extension UIViewController {
    
    func showAlert(title: String,
                   message: String,
                   isCancelButton: Bool? = nil,
                   isOkDestructive: Bool? = nil,
                   okButtonName: String? = nil,
                   
                   customButtons: [UIAlertAction] = [UIAlertAction](),
                   preferredStyle: UIAlertController.Style = .alert,
                   sourceView: UIView? = nil,
                   completion: (() -> Void)? = nil) {
        
        let okDefaultName = "Ок"
        let cancelDefaultName = "Отмена"
        
        func addActionSheetForiPad(actionSheet: UIAlertController) {
            if let popoverPresentationController = actionSheet.popoverPresentationController, let sourceView = sourceView {
                popoverPresentationController.sourceView = sourceView
                popoverPresentationController.sourceRect = sourceView.bounds
                popoverPresentationController.permittedArrowDirections = [.down, .up]
            }
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        
        var allButtons = [UIAlertAction]()
        
        if let okButtonName = okButtonName { //}, !okButtonName!.isEmpty {  //}, isOkDestructive != nil, isOkDestructive! {
            let name = okButtonName.isEmpty ? okDefaultName : okButtonName
            let style: UIAlertAction.Style = isOkDestructive == true ? .destructive : .default
            
            allButtons.append(UIAlertAction(title: name, style: style) { (_) in
                completion?()
            })
        }
        
        
        if !customButtons.isEmpty {
            allButtons += customButtons
        }
        
        if isCancelButton == true {
            let style: UIAlertAction.Style = preferredStyle == .alert ? .default : .cancel
            
            allButtons.append(UIAlertAction(title: cancelDefaultName, style: style))
        }
        
        for button in allButtons {
            alert.addAction(button)
        }
        
        if allButtons.isEmpty {
            alert.addAction(UIAlertAction(title: okDefaultName, style: .cancel) { (_) in
                completion?()
            })
        }
        
        addActionSheetForiPad(actionSheet: alert)
        
        present(alert, animated: true)
    }
}
