//
//  AcceleraBannerView.swift
//  Accelera
//
//  Created by Evgeny Boganov on 22.08.2022.
//

import Foundation
import UIKit

protocol AcceleraBannerViewDelegate: AnyObject {
    func onClose()
    func onAdded()
}

class AcceleraBannerView: UIView {
        
    var closeButtonColor: UIColor = .black
    weak var delegate: AcceleraBannerViewDelegate?
        
    func addMainAcceleraView(_ view: AcceleraAbstractView) {
        self.addSubview(view.view)
        self.backgroundColor = view.element.backgroundColor
        
        if self.backgroundColor?.isLight() == false {
            closeButtonColor = .white
        }
        
        view.view.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = self.safeAreaLayoutGuide
    
        view.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        view.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        view.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        
        self.createCloseButton()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            self.delegate?.onAdded()
        }
    }
    
    private func createCloseButton() {
        let closeButton = UIButton()
        self.addSubview(closeButton)
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(closeButtonColor, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPress), for: .touchUpInside)
        closeButton.startAnimatingPressActions()
        
        let guide = self.safeAreaLayoutGuide
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10).isActive = true
    }
        
    @objc
    private func closeButtonPress() {
        self.delegate?.onClose()
    }
}
