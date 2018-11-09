//
//  SwitchboardJSONTransformer.swift
//  Switchboard
//
//  Created by Rob Phillips on 3/1/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

import Foundation

open class SwitchboardJSONTransformer {
    
    /// Enumerates the current features and experiments and generates JSON from them
    ///
    /// - Parameter switchboard: The Switchboard instance to convert
    /// - Returns: A JSON representation capable of being re-loaded into Switchboard upon relaunch
    open class func convertConfigurationToJSON(for switchboard: Switchboard) -> [String: Any] {
        let experiments = switchboard.experiments
        let inactiveExperiments = switchboard.inactiveExperiments
        let features = switchboard.features
        let inactiveFeatures = switchboard.inactiveFeatures
        
        var config = [String: Any]()
        
        // Active Experiments
        for activeExperiment in experiments {
            var json = activeExperiment.toJSON()
            guard var dictionary = json[activeExperiment.name] as? [String: Any] else { continue }
            dictionary[SwitchboardKeys.isActive] = true
            config[activeExperiment.name] = dictionary
        }
        
        // Inactive Experiments
        for inactiveExperiment in inactiveExperiments {
            var json = inactiveExperiment.toJSON()
            guard var dictionary = json[inactiveExperiment.name] as? [String: Any] else { continue }
            dictionary[SwitchboardKeys.isActive] = false
            config[inactiveExperiment.name] = dictionary
        }
        
        // Active Features
        for activeFeature in features {
            var json = activeFeature.toJSON()
            guard var dictionary = json[activeFeature.name] as? [String: Any] else { continue }
            dictionary[SwitchboardKeys.isActive] = true
            config[activeFeature.name] = dictionary
        }
        
        // Inactive Features
        for inactiveFeature in inactiveFeatures {
            var json = inactiveFeature.toJSON()
            guard var dictionary = json[inactiveFeature.name] as? [String: Any] else { continue }
            dictionary[SwitchboardKeys.isActive] = false
            config[inactiveFeature.name] = dictionary
        }
        
        return config
    }
    
}
