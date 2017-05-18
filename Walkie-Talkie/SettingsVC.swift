//
//  SettingsVC.swift
//  Walkie-Talkie
//
//  Created by Eugene on 27.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import UIKit
import SwiftValidator

class SettingsVC: UIViewController, UITextFieldDelegate {
    
    
    fileprivate let validator = Validator()
    @IBOutlet weak var addressTF: TextField!
    @IBOutlet weak var remotePortTF: TextField!
    @IBOutlet weak var inPortTF: TextField!
    
    fileprivate lazy var accessoryView:AccessoryView = {
        let aView = AccessoryView(30)
        aView.backgroundColor = UIColor.gray
        return aView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        validator.registerField(addressTF, rules:[RequiredRule(message: "address is empty"),IPV4Rule(message: "address is invalid")])
        validator.registerField(remotePortTF, rules: [RequiredRule(message: "remote port is missing"), CharacterSetRule(characterSet: .decimalDigits, message: "port may contain only numbers")])
        validator.registerField(inPortTF, rules: [RequiredRule(message: "in port is missing"), CharacterSetRule(characterSet: .decimalDigits, message: "port may contain only numbers")])
        addressTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let manager = ConnectionManager.manager
        if let inPort = manager.incommingPort {
            inPortTF.text = "\(inPort)"
        }
        if let rmPort = manager.remotePort {
            remotePortTF.text = "\(rmPort)"
        }
        if let rmAddress = manager.remoteAddress {
            addressTF.text = rmAddress
        }else if let wifiAddress = ConnectionManager.getWiFiAddress() {
            let commonAddressPart = wifiAddress.substring(to: wifiAddress.index(after: wifiAddress.indexes(of: ".").last!))
            addressTF.text = commonAddressPart
        }
    }
    
    
    @IBAction func saveParams(_ sender: UIButton)
    {
        
        validator.validate { [unowned self] val_errs in
            
            ConnectionManager.manager.remotePort = Int(self.remotePortTF.text!)
            ConnectionManager.manager.incommingPort = Int(self.inPortTF.text!)
            ConnectionManager.manager.remoteAddress = self.addressTF.text
            
            if val_errs.count > 0  {
                let err_strs = val_errs.map{ $1.errorMessage}.joined(separator: ", ")
                let finalMess = "Holly molly! Validation failed =( Probably, you won't be able to establish connection. Here are some clues for you: " + "\(err_strs)."
                self.showAlert(title: "Oppps", mess: finalMess)
                return
            }
                
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
}


extension SettingsVC{
    
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTF = (textField as? TextField)?.nextResp{
            nextTF.becomeFirstResponder()
        } else{
            textField.resignFirstResponder()
        }
        return false
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        textField.inputAccessoryView = accessoryView
        accessoryView.textField = textField as? TextField
        return true
    }
}
