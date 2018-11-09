//
//  SwitchboardStorable.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public protocol SwitchboardStorable {

    // MARK: - Properties

    /// The namespace for all keys (e.g. `com.keepsafe.switchboard.exp`)
    var namespace: String { get }

    // MARK: - API

    func namespacedKey(for experiment: SwitchboardExperiment, keyName: String) -> String

    func save(bool: Bool?, for experiment: SwitchboardExperiment, forKey key: String)

    func bool(for experiment: SwitchboardExperiment, forKey key: String) -> Bool

}

// MARK: - Default Implementation

extension SwitchboardStorable {

    /// Namespaces the given key for the experiment it's within
    ///
    /// - Parameters:
    ///   - experiment: The `SwitchboardExperiment` to use
    ///   - keyName: The key name, such as `completed`
    /// - Returns: A namespaced key
    public func namespacedKey(for experiment: SwitchboardExperiment, keyName: String) -> String {
        return "\(namespace).\(experiment.name).\(keyName)"
    }
}
