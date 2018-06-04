//
//  Mappable.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Esteban Arrua. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Mappable {
    
    init?(json: JSON?)
    
}
