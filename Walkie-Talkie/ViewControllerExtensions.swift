//
//  ViewControllerExtensions.swift
//  Walkie-Talkie
//
//  Created by Eugene on 17.05.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func showAlert(titles:String, mess:String)
    {
        let aVC = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        aVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(aVC, animated: true, completion: nil)
    }
}
