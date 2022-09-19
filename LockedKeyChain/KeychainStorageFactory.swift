//
//  KeychainStorageFactory.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import Foundation

import KeychainAccess

class KeychainStorageFactory {
    private let localService = "AuthToolkitLocalKeychain"
    private let sharedService = "AuthToolkitSharedKeychain"
    private let sharedBundleIdentifier = "uk.co.bbc.idsso"
    
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
    
    private static let KEYCHAIN_TEST_KEY = "TEST"
    
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
        
        do {
            try keychain.set(Data(), key: KeychainStorageFactory.KEYCHAIN_TEST_KEY)
            _ = try keychain.getData(KeychainStorageFactory.KEYCHAIN_TEST_KEY)
            try keychain.remove(KeychainStorageFactory.KEYCHAIN_TEST_KEY)
            reporter.reportEvent(.createKeychain(.success))
        } catch {
            reporter.reportEvent(.createKeychain(.failure(error.localizedDescription)))
            return nil
        }
        return KeychainStorage(keychain, reporter: reporter)
    }
    
}
