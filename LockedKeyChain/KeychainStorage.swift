//
//  KeychainStorage.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import Foundation
import KeychainAccess

class KeychainStorage: KeyValueStorage {
    private let keychain: Keychain
    
    init(_ keychain: Keychain) {
        self.keychain = keychain
    }
    
    func write(_ data: Data, forKey key: String) {
        try? keychain.set(data, key: key)
    }
    
    func read(_ key: String) -> Data? {
        do {
            return try keychain.getData(key)
        } catch {
            removeAll()
            return nil
        }
    }
    
    func remove(_ key: String) {
        try? keychain.remove(key)
    }
    
    func removeAll() {
        try? keychain.removeAll()
    }
}
