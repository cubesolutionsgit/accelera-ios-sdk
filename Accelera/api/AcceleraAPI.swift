//
//  AcceleraAPI.swift
//  Accelera
//
//  Created by Evgeny Boganov on 15.08.2022.
//

import Foundation

final class AcceleraAPI {
    
    init(config: AcceleraConfig) {
        self.config = config
        self.client = WebClient(baseUrl: config.url)
    }
    
    var client: WebClient
    var config: AcceleraConfig
    
    @discardableResult
    func logEvent(data: [String: Any], completion: @escaping (JSON?, NetworkError?) -> ()) -> URLSessionDataTask? {
        
        var params = JSON()
        params["id"] = config.userId
        params["data"] = data
        
        return client.load(path: "/events/event", method: .post, params: params, headers: ["Authorization": config.token]) { result, error in
            completion(result as? JSON, error)
        }
    }
    
    @discardableResult
    func loadBanner(completion: @escaping (JSON?, NetworkError?) -> ()) -> URLSessionDataTask? {
        
        var params = JSON()
        params["id"] = config.userId
        
        return client.load(path: "/zvuk/template", method: .get, params: params, headers: ["Authorization": config.token]) { result, error in
            completion(result as? JSON, error)
        }
    }
}
