//
//  AcceleraButton.swift
//  Accelera
//
//  Created by Evgeny Boganov on 19.08.2022.
//

import Foundation
import UIKit

class AcceleraButton: AcceleraAbstractView {
    
    init(element: AcceleraRenderingElement, action: ((String) -> Void)?, completion: @escaping () -> Void) {
        super.init(element: element, view: UIButton())
        self.action = action
        
        applyAttributes()
        
        completion()
    }
    
    private var action: ((String) -> Void)?
            
    override func applyAttributes() {
        
        guard let button = self.view as? UIButton else {
            return
        }
        button.clipsToBounds = true
        button.setTitle(element.text, for: .normal)
        button.setTitleColor(element.color, for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        let padding = element.padding ?? UIEdgeInsets(top: 14, left: 40, bottom: 14, right: 40)
        button.contentEdgeInsets = padding
        let fontSize = element.fontSize ?? 15
        let height = button.contentEdgeInsets.top + button.contentEdgeInsets.bottom + fontSize
        button.layer.cornerRadius = height / 2 > 24 ? 24 : height / 2
        button.backgroundColor = element.backgroundColor ?? UIColor(hex: "#0091ff")
        button.titleLabel?.font = button.titleLabel?.font.withSize(fontSize)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.startAnimatingPressActions()
    }
        
    override func setConstraints(parent: AcceleraAbstractView, previousSibling: AcceleraAbstractView?, last: Bool) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
 
        let parentPadding = parent.element.padding ?? UIEdgeInsets.zero
        let selfMargin = self.element.margin ?? UIEdgeInsets.zero
        
        if let width = element.width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        } else {
            view.widthAnchor.constraint(lessThanOrEqualTo: parent.view.widthAnchor).isActive = true
        }
        
        switch parent.element.align {
        case "center":
            view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor).isActive = true
            break
        case "right":
            view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor, constant: -(parentPadding.right + selfMargin.right)).isActive = true
            break
        default:
            view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor, constant: parentPadding.left + selfMargin.left).isActive = true
            break
        }
        
        if let height = element.height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
        if let sibling = previousSibling {
            let siblingMargin = sibling.element.margin ?? UIEdgeInsets.zero
            view.topAnchor.constraint(equalTo: sibling.view.bottomAnchor, constant: siblingMargin.bottom + selfMargin.top).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: parent.view.topAnchor, constant: parentPadding.top + selfMargin.top).isActive = true
        }
        
        if last {
            view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: -(selfMargin.bottom + parentPadding.bottom)).isActive = true
        }
    }
    
    @objc func buttonAction() {
        if let href = element.href, let action = self.action {
            action(href)
        }
    }
}
