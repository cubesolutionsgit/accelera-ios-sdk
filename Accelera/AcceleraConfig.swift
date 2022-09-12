//
//  AcceleraConfig.swift
//  Accelera
//
//  Created by Evgeny Boganov on 15.08.2022.
//

import Foundation

/// Banner type
public enum AcceleraBannerType: String {
    /// Small banner that should be added on top
    case notification
    /// Middle size banner that should be displayed on top
    case top
    /// Middle size banner that should be centered
    case center
    /// Full screen banner
    case fullscreen
}

/// Library configuration
public struct AcceleraConfig {
    /**
     Initializes configuration
     - Parameters:
         - token: application token.
         - url: system url.
         - userId: user identifier.
     */
    public init(token: String, url: String, userId: String) {
        self.token = token
        self.url = url
        self.userId = userId
    }    
    
    let token: String
    let url: String
    let userId: String
}
