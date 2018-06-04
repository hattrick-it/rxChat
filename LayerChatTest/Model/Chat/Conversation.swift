//
//  Conversation.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/14/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import LayerKit
import RxSwift

public class Conversation: NSObject {
    
    // MARK: - Vars
    
    private var conversation: LYRConversation
    
    // MARK: - Public vars
    
    public var originalConversation: LYRConversation {
        return conversation
    }
    
    public var conversationName: String {
        var name : String = ""
        for participant in conversation.participants {
            if(participant.userID != ChatManager.sharedInstance().user?.identity){
                name += participant.displayName ?? "" + " "
            }
        }
        return name
    }
    
    public var lastMessage: Message? {
        guard let message = conversation.lastMessage else {
            return nil
        }
        return Message(message)
    }
    
    // MARK: - RxSwift Inputs
    
    var setNewMessage: AnyObserver<Message> {
        return _newMessage.asObserver()
    }
    
    var setStartTyping: AnyObserver<User> {
        return _startTyping.asObserver()
    }
    
    var setStopTyping: AnyObserver<User> {
        return _stopTyping.asObserver()
    }
    
    var setMessagesUpdated: AnyObserver<Void> {
        return _messagesUpdated.asObserver()
    }
    
    // MARK: - RxSwift Outputs
    
    var newMessage: Observable<Message> {
        return _newMessage.asObservable()
    }
    
    var startTyping: Observable<User> {
        return _startTyping.asObservable()
    }
    
    var stopTyping: Observable<User> {
        return _stopTyping.asObservable()
    }
    
    var messagesUpsdated: Observable<Void> {
        return _messagesUpdated.asObservable()
    }
    
    // MARK: - RxSwift Private Properties
    
    private let _newMessage = PublishSubject<Message>()
    private let _startTyping = PublishSubject<User>()
    private let _stopTyping = PublishSubject<User>()
    private let _messagesUpdated = PublishSubject<Void>()
    
    // MARK: - Public functions
    
    public required init(_ conversation: LYRConversation) {
        self.conversation = conversation
        
        super.init()
    }
    
    public func sendMessage(message: String, completion: @escaping (Bool) -> Void) {
        let newMessage = ChatManager.sharedInstance().createMessage(message: message)
        guard let strongNewMessage = newMessage else {
            completion(false)
            return
        }
        do {
            try self.conversation.send(strongNewMessage.originalMessage)
            completion(true)
        } catch {
            completion(false)
        }
        
    }
    
    public func setTyping(_ isTyping: Bool) {
        if(isTyping) {
            conversation.sendTypingIndicator(.begin)
        }else{
            conversation.sendTypingIndicator(.finish)
        }
    }
    
    public func markAsRead() {
        do {
            try self.conversation.markAllMessagesAsRead()
        } catch { }
    }
    
}
