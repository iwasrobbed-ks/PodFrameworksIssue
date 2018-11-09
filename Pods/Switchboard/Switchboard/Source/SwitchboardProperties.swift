//
//  SwitchboardProperties.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/21/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Foundation
#endif

public struct SwitchboardPropertyKeys {
    public static let osMajorVersion = "os_major_version"
    public static let osVersion = "os_version"
    public static let device = "device"
    public static let lang = "lang"
    public static let manufacturer = "manufacturer"
    public static let country = "country"
    public static let appId = "appId"
    public static let version = "version"
    public static let build = "build"
    public static let uuid = "uuid"
    public static let installId = "installId"
}

open class SwitchboardProperties {

    // MARK: - Public Properties

    public static func defaults(withUuid uuid: String) -> [String: Any] {
        let parameters: [String: Any] = [
            SwitchboardPropertyKeys.uuid: uuid,
            SwitchboardPropertyKeys.osMajorVersion: ProcessInfo().operatingSystemVersion.majorVersion,
            SwitchboardPropertyKeys.osVersion: osVersion,
            SwitchboardPropertyKeys.device: device,
            SwitchboardPropertyKeys.lang: Bundle.main.preferredLocalizations.first!, // This is the language ID for the actual localization of the app, not necessarily the language setting of the device
            SwitchboardPropertyKeys.manufacturer: "Apple",
            SwitchboardPropertyKeys.country: Locale.current.regionCode ?? unknown,
            SwitchboardPropertyKeys.appId: bundleIdentifier,
            SwitchboardPropertyKeys.version: versionName,
            SwitchboardPropertyKeys.build: buildName,
            SwitchboardPropertyKeys.installId: installId
        ]
        return parameters
    }

    // MARK: - Private Properties

    fileprivate static var versionName: String { return bundleValue(for: "CFBundleShortVersionString") }
    fileprivate static var buildName: String { return bundleValue(for: "CFBundleVersion") }
    fileprivate static var bundleIdentifier: String { return bundleValue(for: "CFBundleIdentifier") }
    fileprivate static let unknown = "unknown"
    fileprivate static var osVersion: String {
        #if os(iOS)
            return UIDevice.current.systemVersion
        #elseif os(macOS)
            return ProcessInfo.processInfo.operatingSystemVersionString
        #else
            return unknown
        #endif
    }
    fileprivate static var device: String {
        #if os(iOS)
            return UIDevice.current.model
        #elseif os(macOS)
            var size = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0,  count: size)
            sysctlbyname("hw.model", &machine, &size, nil, 0)
            return String(cString: machine)
        #else
            return unknown
        #endif
    }
    private static let installIdKey = "com.keepsafe.switchboard.properties.installId"
    /// ID generated once per install that is used to assign experiments before the user has a tracking ID/account
    fileprivate static var installId: String {
        if let existingId = UserDefaults.standard.string(forKey: installIdKey) { return existingId }

        let generatedId = NSUUID().uuidString
        UserDefaults.standard.set(generatedId, forKey: installIdKey)
        return generatedId
    }

}

// MARK: - Private API

fileprivate extension SwitchboardProperties {

    static func bundleValue(for key: String) -> String {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? unknown
    }

}
