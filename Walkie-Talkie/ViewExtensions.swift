//
//  UIViewExtensions.swift
//  RealEstate
//
//  Created by Eugene on 01.05.17.
//  Copyright © 2017 RealEstate. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var width:CGFloat{
        set{
            var frame = self.frame
            frame.size = CGSize(width: newValue, height: self.frame.size.height)
            self.frame = frame
        }
        get{
            return self.frame.size.width
        }
    }
    
    var height:CGFloat{
        set{
            var frame = self.frame
            frame.size = CGSize(width: self.frame.size.width, height: newValue)
            self.frame = frame
        }
        get{
            return self.frame.size.height
        }
    }
    
    var size:CGSize{
        set{
            self.frame.size = newValue
        }
        get{
            return self.frame.size
        }
    }
    
    var origin:CGPoint{
        set{
            self.frame.origin = newValue
        }
        get{
            return self.frame.origin
        }
    }
    
    
    var x:CGFloat{
        set{
            self.frame.origin = CGPoint(x: newValue, y: self.frame.origin.y)
        }
        get{
            return self.frame.origin.x
        }
    }
    
    var y:CGFloat{
        set{
            self.frame.origin = CGPoint(x:  self.frame.origin.x, y:newValue)
        }
        get{
            return self.frame.origin.y
        }
    }
}
