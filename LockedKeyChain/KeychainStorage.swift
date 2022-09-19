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
    private let reporter: Reporter
    
    init(_ keychain: Keychain, reporter: Reporter) {
        self.keychain = keychain
        self.reporter = reporter
    }
    
    func write(_ data: Data, forKey key: String) {
        do {
            try keychain.set(data, key: key)
            reporter.reportEvent(.writeKey(.success))
        } catch {
            reporter.reportEvent(.writeKey(.failure(error.localizedDescription)))
        }
    }
    
    func read(_ key: String) -> Data? {
        do {
            let data = try keychain.getData(key)
            reporter.reportEvent(.readKey(.success))
            return data
        } catch {
            reporter.reportEvent(.readKey(.failure(error.localizedDescription)))
            return nil
        }
    }
}
