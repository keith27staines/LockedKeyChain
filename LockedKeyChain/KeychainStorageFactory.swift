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
    private let bundleId: String = ""
    private let teamId: String = ""
    private let sharedService = "sharedKeychain"
    private let sharedBundleIdentifier = "com.keith27staines.LockedKeyChainShared"
    
    var sharedStorage: KeyValueStorage? {
        build(service: sharedService, group: teamId + sharedBundleIdentifier)
    }
    
    var localStorage: KeyValueStorage {
        build(service: localService, group: teamId + bundleId)
    }

    private let reporter: Reporter
    
    init(reporter: Reporter) {
        self.reporter = reporter
    }
    
    private func build(service: String, group: String) -> KeyValueStorage {
        let keychain = Keychain(service: service, accessGroup: group).accessibility(.afterFirstUnlock)
        return KeychainStorage(keychain, reporter: reporter)
    }
    
}
