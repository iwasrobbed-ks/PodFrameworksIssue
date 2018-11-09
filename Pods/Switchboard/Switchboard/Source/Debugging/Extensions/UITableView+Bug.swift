//
//  UITableView+Bug.swift
//  Switchboard
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

extension UITableView {
    
    /// This fixes a bug which enables variable height table headers using autolayout
    /// Source: https://gist.github.com/marcoarment/1105553afba6b4900c10
    func enableVariableHeightTableHeaderView() {
        guard let headerView = tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerWidth = headerView.bounds.size.width
        let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]",
                                                                       options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)),
                                                                       metrics: ["width": headerWidth],
                                                                       views: ["headerView": headerView])
        headerView.addConstraints(temporaryWidthConstraints)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
        
        frame.size.height = height
        headerView.frame = frame
        
        tableHeaderView = headerView
        
        headerView.removeConstraints(temporaryWidthConstraints)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }
    
}
#endif
