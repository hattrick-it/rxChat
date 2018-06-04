//
//  UIViewController+ShowAlert.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(withTitle title: String?, message: String, buttonTitle: String, showCancelButton: Bool = false, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let mainAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        }
        if showCancelButton {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        alertController.addAction(mainAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
