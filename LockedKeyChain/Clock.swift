//
//  Clock.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 19/09/2022.
//

import Foundation


class Clock {

    let start: TimeInterval
    
    init() {
        start = Date().timeIntervalSince1970
    }
    
    var runtime: TimeInterval {
        return Date().timeIntervalSince1970 - start
    }
    
}

