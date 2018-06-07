//
//  User.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/14/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import LayerKit
import RxSwift

public class User: NSObject {
    
    // MARK: - Vars
    
    private var user: LYRIdentity
    
    // MARK: - Public vars
    
    public var identity: String {
        return user.userID
    }
    
    public var displayName: String {
        return user.displayName ?? ""
    }
    
    // MARK: -  RxSwift Properties
    
    let login = Variable<Bool>(false)
    
    // MARK: - RxSwift Outputs
    
    var isLogged: Observable<Bool> {
        return login.asObservable()
    }
    
    // MARK: - RxSwift Private Properties
    
    private let _available = PublishSubject<Bool>()
    
    // MARK: - Public functions
    
    public required init(_ user: LYRIdentity) {
        self.user = user
        
        super.init()
    }
    
}
