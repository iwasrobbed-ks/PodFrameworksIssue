//
//  SwitchboardDefaultStore.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public final class SwitchboardDefaultStore: SwitchboardStorable {

    // MARK: - Instantiation

    public init() {}

    // MARK: - Public Properties

    /// The namespace for all keys
    public let namespace = "com.keepsafe.switchboard.exp"

    // MARK: - API

    /// Stores the boolean value from the key-value store
    ///
    /// - Parameters:
    ///   - bool: A boolean value
    ///   - experiment: The associated `SwitchboardExperiment`
    ///   - key: A key to set within the key-value store
    public func save(bool: Bool?, for experiment: SwitchboardExperiment, forKey key: String) {
        let keyName = namespacedKey(for: experiment, keyName: key)
        UserDefaults.standard.set(bool, forKey: keyName)
    }

    /// Retrieves the boolean value from the key-value store
    ///
    /// - Parameters:
    ///   - experiment: The associated `SwitchboardExperiment`
    ///   - key: A key to retrieve
    /// - Returns: The stored value, if it exists, else false
    public func bool(for experiment: SwitchboardExperiment, forKey key: String) -> Bool {
        let keyName = namespacedKey(for: experiment, keyName: key)
        return UserDefaults.standard.bool(forKey: keyName)
    }
    
}
