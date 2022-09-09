//
//  AcceleraBannerViewController.swift
//  Accelera
//
//  Created by Evgeny Boganov on 16.08.2022.
//

import Foundation
import UIKit

protocol AcceleraViewDelegate: AnyObject {
    func onReady(_ view: UIView, type: AcceleraBannerType)
    func onAdded()
    func onError(_ error: Error)
    func onAction(_ action: String)
    func onClose()
}

class AcceleraBannerViewController {
    
    var view: AcceleraBannerView?
    var bannerType: AcceleraBannerType = .center
    
    weak var delegate: AcceleraViewDelegate?
    
    private var parsingParents = [AcceleraAbstractView]()
    private var preparingGroup: DispatchGroup?
    private var topView: AcceleraAbstractView?
    
    deinit {
        clear()
    }
    
    func create(from html: String, bannerType: AcceleraBannerType) {
        self.bannerType = bannerType
        
        if preparingGroup != nil {
            delegate?.onError("Already creating a banner. Wait for completion")
            return
        }
        
        HTMLParser().parse(html: html) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.delegate?.onError(error)
                break
            case .success(let doc):
                self?.parseElement(doc)
                self?.render()
                
                if let view = self?.view {
                    self?.delegate?.onReady(view, type: bannerType)
                } else {
                    self?.delegate?.onError("View was not created properly")
                }
                break
            }
        }
    }
    
    func clear() {
        if let view = self.view {
            view.removeFromSuperview()
        }
        self.view = nil
        self.preparingGroup = nil
        self.topView = nil
        self.parsingParents.removeAll()
        self.bannerType = .center
    }
    
    @discardableResult
    private func parseElement(_ element: AcceleraRenderingElement) -> AcceleraAbstractView? {
                
        let view = self.createView(element)
        
        if let view = view {
            if let parent = self.parsingParents.last {
                parent.descendents.append(view)
            }
            self.parsingParents.append(view)
        }
        
        element.descendents.forEach { child in
            self.parseElement(child)
        }
        
        if view != nil {
            // assume that we can only have one top element (re-body)
            if self.parsingParents.count == 1 {
                self.topView = self.parsingParents.first
            }
            self.parsingParents.removeLast()
        }
        
        return view
    }
    
    private func render() {
        guard let topView = self.topView else {
            return
        }
        
        let superview = AcceleraBannerView()
        self.view = superview
        superview.delegate = self
        
        superview.addMainAcceleraView(topView)

        // first we need to prepare all views (wait for images to load, set all attributes etc..)
        self.preparingGroup = DispatchGroup()
        topView.descendents.forEach{ child in
            self.prepareView(child)
        }
        self.preparingGroup?.wait()
        self.preparingGroup = nil
        
        // then we render views
        topView.descendents.forEach{ child in
            self.renderView(child, parent: topView)
        }
    }
    
    private func prepareView(_ view:AcceleraAbstractView) {
        self.preparingGroup?.enter()
        view.prepare { [weak self] in
            self?.preparingGroup?.leave()
        }
        view.descendents.forEach{ child in
            self.prepareView(child)
        }
    }
    
    private func renderView(_ view: AcceleraAbstractView, parent: AcceleraAbstractView) {
        parent.view.addSubview(view.view)
        
        view.render(parent: parent, previousSibling: parent.descendents.before(view), last: parent.descendents.last == view)
        
        view.descendents.forEach{ child in
            self.renderView(child, parent: view)
        }
    }
    
    private func createView(_ element: AcceleraRenderingElement) -> AcceleraAbstractView? {
        
        var view: AcceleraAbstractView?
        
        switch element.name {
        case "re-body":
            view = AcceleraBlock(element: element)
            break
        case "re-main":
            view = AcceleraBlock(element: element)
            break
        case "re-block":
            view = AcceleraBlock(element: element)
            break
        case "re-heading":
            view = AcceleraLabel(element: element)
            break
        case "re-text":
            view = AcceleraLabel(element: element)
            break
        case "re-image":
            view = AcceleraImageView(element: element)
            break
        case "re-button":
            view = AcceleraButton(element: element, action: { [weak self] action in  self?.delegate?.onAction(action)})
            break
        default:
            break
        }
        
        if let view = view {
            view.create()
        }
        
        return view
    }
}

extension AcceleraBannerViewController: AcceleraBannerViewDelegate {
    func onClose() {
        self.delegate?.onClose()
    }
    
    func onAdded() {
        self.delegate?.onAdded()
    }
}
