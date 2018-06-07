//
//  Result.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Result<T> {
    
    case success(T?)
    case error(ResultError)
    
}

extension Result where T: Mappable {
    
    init(json: JSON?) {
        if let json = json {
            if json["error"] != JSON.null {
                self = .error(ResultError(json: json))
            } else {
                self = .success(T(json: json))
            }
        } else {
            self = .error(ResultError(type: .noType))
        }
    }
    
}
