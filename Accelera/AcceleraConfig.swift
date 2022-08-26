//
//  AcceleraConfig.swift
//  Accelera
//
//  Created by Evgeny Boganov on 15.08.2022.
//

import Foundation

public enum AcceleraBannerType: String {
    case notification
    case top
    case center
    case fullscreen
}

public struct AcceleraConfig {
    public init(token: String, url: String, userId: String) {
        self.token = token
        self.url = url
        self.userId = userId
    }    
    
    public let token: String
    public let url: String
    public let userId: String
}
