//
//  Accelera.swift
//  Accelera
//
//  Created by Evgeny Boganov on 11.08.2022.
//

import Foundation
import UIKit

public protocol AcceleraDelegate: AnyObject {
    func bannerViewReady(bannerView: UIView, type: AcceleraBannerType)
    func noBannerView()
    @discardableResult
    func bannerViewClosed() -> Bool?
    func bannerViewAction(action: String) -> Bool?
}

public final class Accelera {
    
    public init(config: AcceleraConfig) {
        self.config = config
        self.api = AcceleraAPI(config: config)
        
        viewController.delegate = self
    }
        
    private var config: AcceleraConfig
    private var api: AcceleraAPI
        
    private let queue = DispatchQueue(label: "accelera", qos: .background)
    private var viewController = AcceleraBannerViewController()
    
    weak public var delegate: AcceleraDelegate?
    
    public func logEvent(data: [String: Any]) {
        // TODO: cache if network is not available
        self.api.logEvent(data: data) { [weak self] json, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let json = json {
                print(json)
            }
        }
    }
    
    public func loadBanner() {
        self.api.loadBanner() { [weak self] json, error in
            guard let json = json, json["status"] as! Int == 1, let html = json["template"] as? String else {
                self?.delegate?.noBannerView()
                return
            }
            
            var bannerType: AcceleraBannerType = .top
            
            if let data = json["data"] as? [String: Any],
               let type = data["type"] as? String,
               let bt = AcceleraBannerType(rawValue: type) {
                bannerType = bt
            }
            
            // all views will be created in this thread
            // will show a warning
            self?.queue.async {
                self?.viewController.create(from: html, bannerType: bannerType)
            }
        }
    }
    
    public func getBannerView() -> (view: UIView, bannerType: AcceleraBannerType)? {
        guard let view = viewController.view else {
            return nil
        }
        
        return (view: view, bannerType: viewController.bannerType)
    }
}

extension Accelera: AcceleraViewDelegate {
    func onError(_ error: Error) {
        self.delegate?.noBannerView()
    }
    
    func onReady(_ view: UIView, type: AcceleraBannerType) {
        DispatchQueue.main.async {
            self.delegate?.bannerViewReady(bannerView: view, type: type)
        }
    }
    
    func onAction(_ action: String) {
        let closeAutomatically = self.delegate?.bannerViewAction(action: action)
        if closeAutomatically == true {
            viewController.view?.removeFromSuperview()
        }
        
        viewController.clear()
    }
    
    func onAdded() {
        self.logEvent(data: ["event": "shown"])
    }
    
    func onClose() {
        self.logEvent(data: ["event": "closed"])
        let closeAutomatically = self.delegate?.bannerViewClosed()
        if closeAutomatically == true {
            viewController.view?.removeFromSuperview()
        }
        
        viewController.clear()
    }
}


