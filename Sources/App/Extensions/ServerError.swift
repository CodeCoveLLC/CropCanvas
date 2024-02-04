//
//  File.swift
//  
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor

enum ServerError: AbortError {
    case unknownError
    
    var status: HTTPResponseStatus {
        .internalServerError
    }
    
    var reason: String {
        switch self {
            case .unknownError: "An Unknown Error Occurred"
        }
    }
}
