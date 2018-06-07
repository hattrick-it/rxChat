//
//  ConversationViewModel.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/16/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

class ConversationViewModel {
    
    let disposeBag = DisposeBag()
    
    // MARK: - Public vars
    
    var message = Variable<String>("")
    var typing = Variable<User?>(nil)
    
    // MARK: - Inputs
    
    var getMessages: AnyObserver<Void> {
        return _messages.asObserver()
    }
    
    var getPreviousMessages: AnyObserver<Message> {
        return _previousMessages.asObserver()
    }
    
    var sendMessage: AnyObserver<Void> {
        return _sendMessage.asObserver()
    }
    
    // MARK: - Outputs
    
    var messages: Observable<[Message]> {
        return _messages.asObservable().flatMap { _ in
            self.conversation.rx.getMessages()
        }
    }
    
    var previousMessages: Observable<[Message]> {
        return _previousMessages.asObservable().flatMap { message in
            self.conversation.rx.getMessages(offset: message)
        }
    }
    
    var newMessage: Observable<Message> {
        return _newMessage.asObservable()
    }
    
    var sentMessage: Observable<Bool> {
        return _sendMessage.asObservable().flatMap({ _ in
            self.conversation.rx.sendMessage(message: self.message.value)
        })
    }
    
    var messagesUpdated: Observable<Void> {
        return self.conversation.rx.messagesUpdated
    }
    
    // MARK: - Private vars
    
    private let _messages = PublishSubject<Void>()
    private let _previousMessages = PublishSubject<Message>()
    private let _sendMessage = PublishSubject<Void>()
    private let _newMessage = PublishSubject<Message>()
    
    // MARK: - Public vars
    
    var conversation: Conversation
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.conversation.markAsRead()
        
        self.conversation.rx.newMessage.map({ message -> Message in
            message.markAsRead()
            return message
        }).bind(to: _newMessage.asObserver()).disposed(by: disposeBag)
        
        self.conversation.rx.typingStart
            .bind(to: self.typing)
            .disposed(by: disposeBag)
        
        self.conversation.rx.typingStop.subscribe(onNext: { user in
            if( user.identity == self.typing.value?.identity) {
                self.typing.value = nil
            }
        }).disposed(by: disposeBag)
        
        self.message.asObservable().subscribe(onNext: { message in
            if(message.isEmpty){
                conversation.setTyping(false)
            }else{
                conversation.setTyping(true)
            }
        }).disposed(by: disposeBag)
    }
    
    public func startTyping() {
        
    }
    
    public func stopTyping() {
        
    }
    
}
