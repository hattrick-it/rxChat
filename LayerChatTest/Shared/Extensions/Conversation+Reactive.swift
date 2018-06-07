//
//  Conversation+Reactive.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/16/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: Conversation {
    
    // MARK: - Rx vars
    
    public var newMessage: Observable<Message> {
        return self.base.newMessage
    }
    
    public var typingStart: Observable<User> {
        return self.base.startTyping
    }
    
    public var typingStop: Observable<User> {
        return self.base.stopTyping
    }
    
    public var messagesUpdated: Observable<Void> {
        return self.base.messagesUpsdated
    }
    
    // MARK: - Rx Functions
    
    public func sendMessage(message: String) -> Single<Bool> {
        return Single.create(subscribe: { single -> Disposable in
            self.base.sendMessage(message: message, completion: { success in
                    single(.success(success))
            })
            return Disposables.create { }
        })
    }
    
    public func getMessages(limit: UInt = 20, offset: Message? = nil) -> Single<[Message]> {
        return Single.create(subscribe: { single -> Disposable in
            ChatManager.sharedInstance().getMessages(conversation: self.base, limit: limit, offset: offset, completion: { (messages, error) in
                if error != nil {
                    single(.error(error!))
                }else {
                    single(.success(messages!))
                }
            })
            return Disposables.create { }
        })
    }
    
}
