//
//  ResultError.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import SwiftyJSON

class ResultError: NSError {
    
    enum ErrorType: String {
        case noType = "noType"
    }
    
    static let errorDomain = "myUsersService.com"
    static let defaultErrorMessage = "Something went wrong"
    static let defaultErrorCode = -1
    
    var errorType: ErrorType
    
    init() {
        errorType = .noType
        super.init(domain: ResultError.errorDomain, code: ResultError.defaultErrorCode, userInfo: [NSLocalizedDescriptionKey: ResultError.defaultErrorMessage])
    }
    
    init(code: Int? = nil, message: String? ) {
        let errorMessage = message != nil ? message! : ResultError.defaultErrorMessage
        let userInfo = [NSLocalizedDescriptionKey: errorMessage]
        let errorCode = code != nil ? code! : ResultError.defaultErrorCode
        errorType = .noType
        super.init(domain: ResultError.errorDomain, code: errorCode, userInfo: userInfo)
    }
    
    convenience init(json: JSON?) {
        let message = json?["error"].string ?? ""
        self.init(message: message)
        if let errorTypeString = json?["error"].string, let errorType = ErrorType.init(rawValue: errorTypeString) {
            self.errorType = errorType
        } else {
            self.errorType = .noType
        }
    }
    
    convenience init (type: ErrorType) {
        self.init()
        errorType = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
