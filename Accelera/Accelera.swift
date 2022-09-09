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
    @discardableResult func bannerViewClosed() -> Bool?
    @discardableResult func bannerViewAction(action: String) -> Bool?
}

public final class Accelera {
    
    public init(config: AcceleraConfig) {
        self.config = config
        self.viewController.delegate = self
    }
    
    private var config: AcceleraConfig
    
    private var _api: AcceleraAPI?
    private var api: AcceleraAPI {
        get {
            if let api = self._api {
                return api
            }
            let api = AcceleraAPI(config: self.config)
            self._api = api
            return api
        }
    }
        
    private let queue = DispatchQueue(label: "ru.cubesolutions.accelera", qos: .background)
    
    private var _viewController: AcceleraBannerViewController?
    private var viewController: AcceleraBannerViewController {
        get {
            if let vc = self._viewController {
                return vc
            }
            let vc = AcceleraBannerViewController()
            vc.delegate = self
            self._viewController = vc
            return vc
        }
    }
    
    weak public var delegate: AcceleraDelegate?
    
    public func logEvent(data: [String: Any]) {
        self.queue.async {
            // TODO: cache if network is not available
            self.api.logEvent(data: data) { [weak self] json, error in
                self?.queue.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let json = json {
                        print(json)
                    }
                }
            }
        }
    }
    
    public func loadBanner() {
        self.queue.async {
            self.api.loadBanner() { [weak self] json, error in
                self?.queue.async {
                    guard let json = json, let status = json["status"] as? Int, status == 1, let html = json["template"] as? String else {
                        self?.delegate?.noBannerView()
                        return
                    }
                    
                    var bannerType: AcceleraBannerType = .top
                    
                    if let data = json["data"] as? [String: Any],
                       let type = data["type"] as? String,
                       let bt = AcceleraBannerType(rawValue: type) {
                        bannerType = bt
                    }
                    
                    self?.viewController.create(from: html, bannerType: bannerType)
                }
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


