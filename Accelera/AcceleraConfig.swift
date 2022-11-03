//
//  AcceleraConfig.swift
//  Accelera
//
//  Created by Evgeny Boganov on 15.08.2022.
//

import Foundation

/// Banner type
public enum AcceleraBannerType: String {
    /// Small banner that will be added on top of the screen
    case notification
    /// Middle size banner that will be displayed on top of the screen
    case top
    /// Middle size banner that will be centered
    case center
    /// Full screen banner
    case fullscreen
}

/// Library configuration
public struct AcceleraConfig {
    /**
     Initializes configuration
     
     - Parameters:
         - token: application token provided by the Accelera.
         - url: system url.
         - userId: user unique identifier.
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
