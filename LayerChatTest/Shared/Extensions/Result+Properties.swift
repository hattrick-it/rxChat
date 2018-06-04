//
//  Result+Properties.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 6/6/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation

extension Result {
    
    var successValue: T? {
        switch self {
        case .success(let value):
            return value
        case .error:
            return nil
        }
    }
    
    var errorValue: ResultError? {
        switch self {
        case .error(let error):
            return error
        case .success:
            return nil
        }
    }
    
    var isSuccessful: Bool {
        if case .success = self {
            return true
        } else {
            return false
        }
    }
    
    var isError: Bool {
        if case .error = self {
            return true
        } else {
            return false
        }
    }
    
}
