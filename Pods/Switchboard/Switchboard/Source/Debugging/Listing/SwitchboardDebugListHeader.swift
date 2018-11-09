//
//  SwitchboardDebugListHeader.swift
//  Switchboard
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugListHeader: UIView {
    
    // MARK: - Instantiation
    
    /// Instantiates the header with the given callbacks
    init(enableAllTapped: @escaping SwitchboardDebugTapClosure,
         disableAllTappped: @escaping SwitchboardDebugTapClosure) {
        self.enableAllTapped = enableAllTapped
        self.disableAllTapped = disableAllTappped
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    // MARK: - Private Properties
    
    fileprivate let enableAllTapped: SwitchboardDebugTapClosure
    fileprivate let disableAllTapped: SwitchboardDebugTapClosure
    
    // MARK: - Unsupported Initializers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate extension SwitchboardDebugListHeader {
    
    func setupView() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        let buttonHeight: CGFloat = 44
        
        let enableAllButton = UIButton(type: .custom)
        enableAllButton.setTitleColor(self.tintColor, for: .normal)
        enableAllButton.addTarget(self, action: #selector(enableAllButtonTapped), for: .touchUpInside)
        enableAllButton.setTitle("Enable All", for: .normal)
        enableAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let disableAllButton = UIButton(type: .custom)
        disableAllButton.setTitleColor(self.tintColor, for: .normal)
        disableAllButton.addTarget(self, action: #selector(disableAllButtonTapped), for: .touchUpInside)
        disableAllButton.setTitle("Disable All", for: .normal)
        disableAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView(arrangedSubviews: [enableAllButton, disableAllButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.backgroundColor = .clear
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        NSLayoutConstraint.activate([buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     buttonStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     buttonStack.heightAnchor.constraint(equalToConstant: buttonHeight)])
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(red: 214/255, green: 70/255, blue: 53/255, alpha: 1)
        addSubview(divider)
        NSLayoutConstraint.activate([divider.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 10),
                                     divider.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     divider.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     divider.heightAnchor.constraint(equalToConstant: 3),
                                     divider.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    @objc func enableAllButtonTapped() {
        enableAllTapped()
    }
    
    @objc func disableAllButtonTapped() {
        disableAllTapped()
    }
    
}
#endif
