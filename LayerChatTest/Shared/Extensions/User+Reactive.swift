//
//  User+Reactive.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/18/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: User {
    
    // MARK: - Rx vars
    
    public var logged: Observable<Bool> {
        return self.base.isLogged
    }
    
}

