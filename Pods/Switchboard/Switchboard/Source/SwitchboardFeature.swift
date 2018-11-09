//
//  SwitchboardFeature.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

/// Factory class for instantiating many features from a JSON dictionary
open class SwitchboardFeatureFactory {

    // MARK: - Instantiation

    /// Instantiates an array of active `SwitchboardFeature` instances that apply to the person
    ///
    /// - Parameters:
    ///   - json: A valid JSON dictionary returned from the Switchboard server
    ///   - analytics: An optional analytics provider, conforming to `SwitchboardAnalyticsProvider`, to log events to
    ///   - active: Whether to return active or inactive features
    /// - Returns: An array of `SwitchboardExperiment` instances, if any
    open class func from(json: [String : Any], analytics: SwitchboardAnalyticsProvider? = nil, active: Bool = true) -> Set<SwitchboardFeature> {
        var instances = Set<SwitchboardFeature>()
        for key in Array(json.keys) {
            guard let dictionary = json[key] as? [String: Any] else { continue }

            let isActive = dictionary[SwitchboardKeys.isActive] as? Bool
            guard isActive == active else { continue }

            let values = dictionary[SwitchboardKeys.values] as? [String: Any]
            if let instance = SwitchboardFeature(name: key, values: values, analytics: analytics) {
                instances.insert(instance)
            }
        }
        SwitchboardPrefillController.shared.add(features: instances)
        return instances
    }

}

/// Base class to encapsulate feature meta data
open class SwitchboardFeature: NSObject, SwitchboardValue {

    // MARK: - Instantiation

    /// Instantiates a active feature that applies to the person
    ///
    /// Note: This will return `nil` if the `values` dictionary contains a non-nil `cohort` key (since that is considered an experiment)
    ///
    /// - Parameters:
    ///   - name: The name of the experiment or feature
    ///   - values: An optional dictionary of associated values
    ///   - analytics: An optional analytics provider, conforming to `SwitchboardAnalyticsProvider`, to log events to
    public required init?(name: String, values: [String: Any]? = nil, analytics: SwitchboardAnalyticsProvider? = nil) {
        self.name = name
        // Features must not be part of a cohort, otherwise they're considered experiments
        guard values?[SwitchboardKeys.cohort] == nil else {
            return nil
        }
        self.values = values
        self.analytics = analytics
    }

    // MARK: - Public Properties

    /// The name of the experiment or feature
    public let name: String

    /// A dictionary of values associated with this feature
    ///
    /// Note: we allow overrides via debug controller
    open var values: [String: Any]?

    /// Whether analytics should be tracked for this feature, given as a boolean within the `values` dictionary
    open var shouldTrackAnalytics: Bool {
        guard let shouldDisableAnalytics = values?[SwitchboardKeys.disableAnalytics] as? Bool else { return true }
        return shouldDisableAnalytics == false
    }

    // MARK: - API

    /// Tracks an event associated with this feature
    ///
    /// - Parameters:
    ///   - event: A `String` event to track
    ///   - properties: A dictionary of optional properties
    open func track(event: String, properties: [String : Any]? = nil) {
        if shouldTrackAnalytics {
            analytics?.track(event: event, for: self, properties: properties)
        }
    }

    // MARK: - NSCoding

    public convenience required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: SwitchboardNSCodingKeys.name) as? String else { return nil }
        let values = aDecoder.decodeObject(forKey: SwitchboardNSCodingKeys.values) as? [String: Any]

        self.init(name: name, values: values)
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: SwitchboardNSCodingKeys.name)
        if let values = values {
            aCoder.encode(values, forKey: SwitchboardNSCodingKeys.values)
        }
    }

    // MARK: - Private Properties

    fileprivate let analytics: SwitchboardAnalyticsProvider?

}

// MARK: - SwitchboardJSONTransformable

extension SwitchboardFeature: SwitchboardJSONTransformable {
    
    public func toJSON() -> [String: Any] {
        let valuesValue: Any = values ?? "<null>"
        return [name: [SwitchboardKeys.values: valuesValue]]
    }
    
}

// MARK: - Description

extension SwitchboardFeature {

    open override var description: String {
        var valuesString = "nil"
        if let values = values { valuesString = String(describing: values) }
        return "<SwitchboardFeature: name: \"\(name)\" values: \(valuesString)>\n"
    }

}

// MARK: - Equatable

extension SwitchboardFeature {

    open override func isEqual(_ otherObject: Any?) -> Bool {
        guard let feature = otherObject as? SwitchboardFeature else { return false }
        return name == feature.name
    }
    
}

// MARK: - Hashable

extension SwitchboardFeature {

    open override var hash: Int {
        return name.hashValue
    }

}
