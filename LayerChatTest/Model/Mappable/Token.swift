//
//  Token.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import SwiftyJSON

class Token: Mappable {
    
    var identity: String
    
    required init?(json: JSON?) {
        guard let identity = json?["identity_token"].string else { return nil }
        self.identity = identity
    }
    
}
