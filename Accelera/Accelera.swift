//
//  Accelera.swift
//  Accelera
//
//  Created by Evgeny Boganov on 11.08.2022.
//

import Foundation
import UIKit


/// Delegate that informs about banner events
public protocol AcceleraDelegate: AnyObject {
    /**
     When view is ready delegate calls this method
     - Parameters:
         - view: UIView that was prepared by the library
         - type: Type of the banner. See ``AcceleraBannerType``
     */
    func bannerViewReady(view: UIView, type: AcceleraBannerType)
    
    /**
     If banner doesn't exist then library will call this delegate method
     */
    func noBannerView()
    
    /**
     Called when close button was pressed
     - Returns: Optional boolean. If true library will remove banner from its superview automatically
     */
    @discardableResult func bannerViewClosed() -> Bool?
    /**
     Called when close button was pressed
     - Parameters:
          - action: optional string set as button action
     - Returns: Optional boolean. If true library will remove banner from its superview automatically
     */
    @discardableResult func bannerViewAction(action: String?) -> Bool?
}

/// Main library class
public final class Accelera {
    
    /**
     Initializes library
     - Parameters:
         - config: Library configuration. See ``AcceleraConfig``
     */
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
    
    /**
     Sets delegate for library events. See ``AcceleraDelegate``
     */
    weak public var delegate: AcceleraDelegate?
    
    /**
     Logs event for user activity
     - Parameters:
         - data: Valid JSON string that describes the event
     */
    public func logEvent(string: String) {
        self.queue.async {
            // TODO: cache if network is not available
            if let data = string.data(using: .utf8),
               let object = try? JSONSerialization.jsonObject(with: data, options: []),
               let json = object as? JSON {
                self.api.logEvent(data: json) { [weak self] json, error in
                    self?.queue.async {
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let json = json {
                            print(json)
                        }
                    }
                }
            } else {
                print("bad json sent to log event")
            }
        }
    }
    
    /**
     Asks if any type of banner for current user exists
     will call delegate in any case. See ``AcceleraDelegate``
     */
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
                    
                    // some crazy code for switching between threads
                    self?.queue.async {
                        self?.viewController.parseHTML(html: html, completion: {
                            DispatchQueue.main.async {
                                self?.viewController.createViews {
                                    self?.queue.async {
                                        self?.viewController.prepareViews {
                                            DispatchQueue.main.async {
                                                self?.viewController.renderViews(type: bannerType, completion: {
                                                    
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    /**
     Will return banner view if it was loaded previously.
     - Returns: Tuple with **view** as banner view and **type** as its type.
     This is just a convenience method. Need to call ``loadBanner()`` first
     */
    public func getBannerView() -> (view: UIView, type: AcceleraBannerType)? {
        guard let view = viewController.view else {
            return nil
        }
        
        return (view: view, type: viewController.bannerType)
    }
}

extension Accelera: AcceleraViewDelegate {
    func onError(_ error: Error) {
        self.delegate?.noBannerView()
    }
    
    func onReady(_ view: UIView, type: AcceleraBannerType) {
        DispatchQueue.main.async {
            self.delegate?.bannerViewReady(view: view, type: type)
        }
    }
    
    func onAction(_ action: String?) {
        let closeAutomatically = self.delegate?.bannerViewAction(action: action)
        if closeAutomatically == true {
            viewController.view?.removeFromSuperview()
            viewController.clear()
        }
    }
    
    func onAdded() {
        self.logEvent(string: "{\"event\": \"shown\"}")
    }
    
    func onClose() {
        self.logEvent(string: "{\"event\": \"closed\"}")
        let closeAutomatically = self.delegate?.bannerViewClosed()
        if closeAutomatically == true {
            viewController.view?.removeFromSuperview()
            viewController.clear()
        }
        
        
    }
}


