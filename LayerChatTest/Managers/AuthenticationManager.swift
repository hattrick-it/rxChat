//
//  AuthenticationManager.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

class AuthenticationManager {
    
    let disposeBag = DisposeBag()
    
    static let sharedInstance = AuthenticationManager()
    
    // MARK: - Public methods
    
    func authentication(email: String, pass: String, nonce: String) -> Observable<Result<Token>> {
        return RequestHelper.sharedInstance().performRequest(endopoint: .authenticate(email: email, password: pass, nonce: nonce))
    }
    
}
