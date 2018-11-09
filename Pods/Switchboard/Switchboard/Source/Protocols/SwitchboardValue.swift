//
//  SwitchboardValue.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public struct SwitchboardNSCodingKeys {
    static let name = "name"
    static let values = "values"
    static let availableCohorts = "availableCohorts"
}

public protocol SwitchboardValue: NSObjectProtocol, NSCoding {

    // MARK: - Public Properties

    var name: String { get }

}

public protocol SwitchboardJSONTransformable {
    
    // MARK: - API
    
    func toJSON() -> [String: Any]
    
}
