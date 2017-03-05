//
//  RoundedCornerView.swift
//  Walkie-Talkie
//
//  Created by Eugene on 27.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    @IBInspectable private var cornerRadius:CGFloat{
        set{
            self.layer.cornerRadius = CGFloat(newValue)
        }
        get{
            return self.layer.cornerRadius
        }
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
    }

}
