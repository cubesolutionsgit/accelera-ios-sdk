//
//  AcceleraAbstractView.swift
//  Accelera
//
//  Created by Evgeny Boganov on 19.08.2022.
//

import Foundation
import UIKit

class AcceleraAbstractView: Equatable {
    
    init(element: AcceleraRenderingElement, view: UIView) {
        self.element = element
        self.view = view
    }
        
    var id = UUID()
    var element: AcceleraRenderingElement
    var view: UIView
    var descendents = [AcceleraAbstractView]()
    
    internal func applyAttributes() {
        
    }
    
    func setConstraints(parent: AcceleraAbstractView, previousSibling: AcceleraAbstractView?, last: Bool) {
        
    }
    
    static func == (lhs: AcceleraAbstractView, rhs: AcceleraAbstractView) -> Bool {
        return lhs.id == rhs.id
      }
}

extension AcceleraAbstractView: CustomStringConvertible {
    var description: String {
        return "\n\(id)\nelement: \(element)\ndescendents: \(descendents)\n"
    }
}
