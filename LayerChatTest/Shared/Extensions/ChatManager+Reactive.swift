//
//  ChatManager+Reactive.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: ChatManager {
    
    // MARK: - Rx Vars
    
    public var conversations: Single<[Conversation]> {
        return Single.create(subscribe: { single -> Disposable in
            self.base.getConversations(completion: { (conversations, error) in
                if error != nil {
                    single(.error(error!))
                } else {
                    single(.success(conversations!))
                }
            })
            return Disposables.create { }
        })
    }
    
    // MARK: - Rx Functions
    
    func authenticate(email: String, pass: String) -> Single<Result<User>> {
        return Single.create(subscribe: { single -> Disposable in
            self.base.authenticate(email: email, password: pass, completion: { result in
                single(.success(result))
            })
            return Disposables.create { }
        })
    }
    
    public func deauthenticate() -> Single<Bool> {
        return Single.create(subscribe: { single -> Disposable in
            self.base.deauthenticate(completion: { (success, error) in
                if let error = error {
                    single(.error(error))
                } else {
                    self.base.deauthenticateSuccess()
                    single(.success(success))
                }
            })
            return Disposables.create { }
        })
    }
    
    public func newConversation(participants: [String]) -> Single<Conversation> {
        return Single.create(subscribe: { single -> Disposable in
            self.base.createConversation(participants: participants, completion: { conversation, error in
                if let error = error {
                    single(.error(error))
                } else {
                    single(.success(conversation!))
                }
            })
            return Disposables.create { }
        })
    }

}
