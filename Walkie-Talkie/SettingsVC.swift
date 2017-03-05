//
//  SettingsVC.swift
//  Walkie-Talkie
//
//  Created by Eugene on 27.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var addressTF: UITextField!
    
    @IBOutlet weak var remotePortTF: UITextField!
    @IBOutlet weak var inPortTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let manager = ConnectionManager.manager
        if let inPort = manager.incommingPort {
            inPortTF.text = "\(inPort)"
        }
        if let rmPort = manager.remotePort {
            remotePortTF.text = "\(rmPort)"
        }
        addressTF.text = manager.remoteAddress
    }
    
    
    @IBAction func sveParams(_ sender: UIButton) {
        let alertClosure = {
            let alert = UIAlertController(title: "Error", message: "Not all required fields are filled. The connection will not be established.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if let inPort = inPortTF.text, let rmPort = remotePortTF.text,  let address = addressTF.text {
            
            
            if (inPort.characters.count == 0 || rmPort.characters.count == 0 || address.characters.count == 0){
                alertClosure()
            } else{
                ConnectionManager.manager.remotePort = Int(rmPort)
                ConnectionManager.manager.incommingPort = Int(inPort)
                ConnectionManager.manager.remoteAddress = address
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }else{
            alertClosure()
        }

    }
    
}
