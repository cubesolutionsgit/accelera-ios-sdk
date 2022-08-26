//
//  AcceleraImageView.swift
//  Accelera
//
//  Created by Evgeny Boganov on 19.08.2022.
//

import Foundation
import UIKit

class AcceleraImageView: AcceleraAbstractView {
    
    init(element: AcceleraRenderingElement, completion: @escaping () -> Void) {
        self.completion = completion
        super.init(element: element, view: UIImageView())
        applyAttributes()
    }
    
    let completion: () -> Void
    
    override func applyAttributes() {
        
        defer {
            self.completion()
        }
        
        guard let imageView = self.view as? UIImageView else {
            return
        }
        
        imageView.contentMode = .scaleAspectFill
        
        if let source = element.getAttribute("src"), !source.isEmpty,
           let url = URL(string: source) {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                    
                    let imageRatio = image.size.width / image.size.height
                    
                    let width: CGFloat? = element.width
                    let height: CGFloat? = element.height
                    
                    if height == nil && width != nil {
                        view.heightAnchor.constraint(equalToConstant: width! / imageRatio).isActive = true
                    }
                    
                    if (width == nil && height != nil) {
                        view.widthAnchor.constraint(equalToConstant: height! * imageRatio).isActive = true
                    }
                }
            }
        }
    }
    
    override func setConstraints(parent: AcceleraAbstractView, previousSibling: AcceleraAbstractView?, last: Bool) {
              
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let parentPadding = parent.element.padding ?? UIEdgeInsets.zero
        let selfMargin = self.element.margin ?? UIEdgeInsets.zero
        
        if let width = element.width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
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
        } else {
            view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor, constant: parentPadding.left + selfMargin.left).isActive = true
            view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor, constant: -(parentPadding.right + selfMargin.right)).isActive = true
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
}
