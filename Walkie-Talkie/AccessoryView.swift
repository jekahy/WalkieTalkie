//
//  AccessoryView.swift
//  Walkie-Talkie
//
//  Created by Eugene on 18.05.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import UIKit


class AccessoryView: UIToolbar {

    weak var textField:TextField?
    
    init(_ height:Int = 30)
    {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        
        barStyle = .default
        isTranslucent = true
        sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped(_:)))
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        
        let nextButton = UIButton(type: .custom)
        nextButton.tintColor = UIColor.blue
        nextButton.setImage(UIImage(named: "arrow_right"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)
        nextButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        let nextBarButton  = UIBarButtonItem(customView: nextButton)
    
        let previousButton = UIButton(type: .custom)
        previousButton.setImage(UIImage(named: "arrow_left"), for: .normal)
        previousButton.addTarget(self, action: #selector(prevTapped(_:)), for: .touchUpInside)
        previousButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let previousBarButton  = UIBarButtonItem(customView: previousButton)
        
        setItems([fixedSpaceButton, previousBarButton, fixedSpaceButton,  nextBarButton , flexibleSpaceButton, doneButton], animated: false)
        isUserInteractionEnabled = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func nextTapped(_ sender:UIBarButtonItem)
    {

        textField?.nextResp?.becomeFirstResponder()
    }
    
    @objc private func prevTapped(_ sender:UIBarButtonItem)
    {
        textField?.prevResp?.becomeFirstResponder()
    }
    
    @objc private func doneTapped(_ sender:UIBarButtonItem)
    {
        textField?.resignFirstResponder()
    }
}

