//
//  KeychainStorageFactory.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import Foundation

import KeychainAccess

let KEYCHAIN_TEST_KEY: String = "TEST"

class KeychainStorageFactory {
    private let localService = "localKeyChain"
    private let sharedService = "sharedKeychain"
    private let sharedBundleIdentifier = "com.keith27staines.LockedKeyChain"
    
    var sharedStorage: KeyValueStorage? {
        if let teamIdentifier = teamID {
            return build(service: sharedService, group: teamIdentifier + sharedBundleIdentifier)
        }
        return nil
    }
    
    var localStorage: KeyValueStorage? {
        if let teamIdentifier = teamID, let bundleIdentifier = bundleID {
            return build(service: localService, group: teamIdentifier + bundleIdentifier)
        }
        return nil
    }
    
    private let teamID: String?
    private let bundleID: String?
    private let reporter: Reporter
    
    init(_ teamID: String?, _ bundleID: String?, reporter: Reporter) {
        self.teamID = teamID
        self.bundleID = bundleID
        self.reporter = reporter
    }
    
    private func build(service: String, group: String) -> KeyValueStorage? {
        let keychain = Keychain(service: service, accessGroup: group).accessibility(.afterFirstUnlock)
        return KeychainStorage(keychain, reporter: reporter)
    }
    
}
