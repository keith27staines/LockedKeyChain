//
//  LockedKeyChainApp.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import SwiftUI

@main
struct LockedKeyChainApp: App {
    
    init() {
        setupAirship()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension LockedKeyChainApp {
    func setupAirship() {
        
    }
}
