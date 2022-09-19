//
//  KeyValueStorage.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import Foundation

protocol KeyValueStorage {
    func write(_ data: Data, forKey key: String)
    func read(_ key: String) -> Data?
}
