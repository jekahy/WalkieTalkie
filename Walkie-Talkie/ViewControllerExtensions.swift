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
    
    func showAlert(title:String, mess:String, completion:((UIAlertAction)->())?=nil)
    {
        let aVC = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        aVC.addAction(UIAlertAction(title: "OK", style: .default, handler:completion))
        self.present(aVC, animated: true, completion: nil)
    }
}
