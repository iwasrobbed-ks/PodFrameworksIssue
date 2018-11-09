//
//  SwitchboardPrefillListView.swift
//  Switchboard
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
    import UIKit
    
    /// Base controller for showing a prefill selection list
    internal class SwitchboardPrefillListView: UITableViewController {
        
        // MARK: - Instantiation
        
        init(prefillController: SwitchboardPrefillController = SwitchboardPrefillController.shared) {
            self.prefillController = prefillController
            
            super.init(style: .plain)
            
            setupView()
        }
        
        // MARK: - Properties
        
        var debugTitle: String { return "" }
        weak var prefillController: SwitchboardPrefillController?
        
        // MARK: - API
        
        func setupView() {
            title = debugTitle
            navigationItem.backBarButtonItem?.title = ""
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
            
            tableView.backgroundColor = SwitchboardColors.tableBackground
            tableView.rowHeight = 60
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.register(SwitchboardDebugTapCell.self, forCellReuseIdentifier: SwitchboardDebugTapCell.reuseIdentifier)
        }
        
        // MARK: - UITableViewDataSource
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            fatalError("override necessary")
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            fatalError("override necessary")
        }
        
        // MARK: - Unsupported Initializers
        
        required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    }
    
    // MARK: - Private API
    
    fileprivate extension SwitchboardPrefillListView {
        
        @objc func cancelTapped() {
            dismiss(animated: true, completion: nil)
        }
        
    }
#endif
