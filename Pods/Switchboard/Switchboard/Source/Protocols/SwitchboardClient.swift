//
//  SwitchboardClient.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public typealias SwitchboardClientCompletion = (_ error: Error?) -> ()

/// Base protocol for creating your own implementation
public protocol SwitchboardClient {

    // MARK: - Public Properties

    var experiments: Set<SwitchboardExperiment> { get set }
    var features: Set<SwitchboardFeature> { get set }

    // MARK: - API

    func activate(serverUrlString: String, completion: SwitchboardClientCompletion?)

    func downloadConfiguration(for uuid: String, userData: [String: Any]?, completion: SwitchboardClientCompletion?)

    func isIn(experimentNamed experimentName: String, defaultValue: Bool) -> Bool

    func isNotIn(experimentNamed experimentName: String, defaultValue: Bool) -> Bool

    func isEnabled(featureNamed featureName: String, defaultValue: Bool) -> Bool

    func isNotEnabled(featureNamed featureName: String, defaultValue: Bool) -> Bool

}
