//
//  Platform.swift
//  Walkie-Talkie
//
//  Created by Eugene on 17.05.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    
}
