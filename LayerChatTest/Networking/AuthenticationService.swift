//
//  AuthenticationService.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Esteban Arrua. All rights reserved.
//

import Foundation
import Moya

enum ApiVersion: String {
    case none = ""
}

enum AuthenticationService {
    case authenticate(email: String, password: String, nonce: String)
}

extension AuthenticationService: TargetType {
    
    var apiVersion: ApiVersion { return .none }
    
    // MARK: - TargetType Protocol Implementation
    var baseURL: URL { return URL(string: "myUsersService.com" + apiVersion.rawValue)!}
    
    var path: String {
        switch self {
        case .authenticate(_):
            return "/authenticate"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .authenticate(_):
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .authenticate(let email, let password, let nonce):
            return .requestParameters(parameters: ["email": email, "password": password, "nonce": nonce], encoding: JSONEncoding.default)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .authenticate(_):
            return Data()
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}
