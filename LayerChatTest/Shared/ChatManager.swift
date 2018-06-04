//
//  ChatManager.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import LayerKit
import RxSwift

public class ChatManager: NSObject, LYRClientDelegate, LYRQueryControllerDelegate {
    
    // MARK: - Singleton
    fileprivate static let instance = ChatManager()
    
    class func sharedInstance() -> ChatManager {
        return instance
    }
    
    fileprivate override init() {
        super.init()
        
        let clientOptions = LYRClientOptions()
        clientOptions.synchronizationPolicy = .completeHistory
        self.layerClient = LYRClient(appID: appID, delegate: self, options: clientOptions)
        self.layerClient?.connect(completion: { _,  _ in
        })
        if (self.layerClient?.authenticatedUser != nil) {
            self.user = User(self.layerClient!.authenticatedUser!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveLayerObjectsDidChangeNotification), name: NSNotification.Name.LYRClientObjectsDidChange, object: layerClient)
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveTypingIndicator), name: NSNotification.Name.LYRConversationDidReceiveTypingIndicator, object: nil)
    }
    
    // MARK: - Constatns
    
    let appID = URL(string: "layerAppId")!
    
    // MARK: - Variables
    
    var layerClient: LYRClient?
    var disposeBag = DisposeBag()
    
    // MARK: - Public vars
    
    public var user: User?

    // MARK: - Private vars
    
    fileprivate var conversations: [URL:Conversation] = [:]
    
    // MARK: - Functions
    
    func authenticate(email: String, password: String, completion: @escaping (Result<User>) -> Void) {
        self.layerClient?.requestAuthenticationNonce(completion: { (nonce, error) in
            guard let nonce = nonce else {
                return
            }
            AuthenticationManager.sharedInstance.authentication(email: email, pass: password, nonce: nonce).subscribe(onNext: { result in
                switch result {
                case .success(let token):
                    self.layerClient?.authenticate(withIdentityToken: token!.identity, completion: { (authenticatedUser, error) in
                        if authenticatedUser != nil {
                            self.user = User(authenticatedUser!)
                            completion(.success(self.user))
                        }
                    })
                case .error(let error):
                    completion(.error(error))
                }
            }).disposed(by: self.disposeBag)
        })
    }
    
    func deauthenticate(completion: @escaping (Bool, Error?) -> Void) {
        self.layerClient?.deauthenticate(completion: completion)
    }
    
    func deauthenticateSuccess(){
        user = nil
        conversations = [:]
    }
    
    func getConversations(completion: @escaping ([Conversation]?, Error?) -> Void) {
        let query = LYRQuery(queryableClass: LYRConversation.self)
        
        do {
            let queryController = try layerClient?.queryController(with: query)
            queryController?.delegate = self
            try queryController?.execute()
            guard let objects = queryController?.allObjects else {
                completion(nil, ResultError(message: "Query fail"))
                return
            }
            var conversations: [Conversation] = []
            for object in objects {
                let conversation = Conversation(object as! LYRConversation)
                conversations.append(conversation)
                self.conversations[conversation.originalConversation.identifier] = conversation
            }
            completion(conversations, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func createConversation(participants: [String], completion: @escaping (Conversation?, Error?) -> Void) {
        do {
            let setParticipants = Set(participants)
            let conversation = try layerClient?.newConversation(withParticipants: setParticipants, options: nil)
            
            // The first message is sent to create the conversation in the server. 
            let message = try layerClient?.newMessage(with: [LYRMessagePart(text: "Hola")], options: nil)
            try conversation?.send(message!)
            completion(Conversation(conversation!), nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func createMessage(message: String) -> Message? {
        do {
            let notificationConfiguration = LYRPushNotificationConfiguration()
            notificationConfiguration.alert = message
            
            let messageOptions = LYRMessageOptions()
            messageOptions.pushNotificationConfiguration = notificationConfiguration
            
            let newMessage = try layerClient?.newMessage(with: [LYRMessagePart(text: message)], options: messageOptions)
            return Message(newMessage!)
        } catch {
            return nil
        }
    }
    
    func getMessages(conversation: Conversation, limit: UInt, offset: Message?, completion: @escaping ([Message]?, Error?) -> Void) {
        do {
            let query = LYRQuery(queryableClass: LYRMessage.self)
            var subpredicates: [LYRPredicate] = [LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.isEqualTo, value: conversation.originalConversation)]
            if(offset != nil) {
                subpredicates.append(LYRPredicate(property: "position", predicateOperator: LYRPredicateOperator.isLessThan, value: offset?.originalMessage.position))
            }
            query.predicate = LYRCompoundPredicate(type: LYRCompoundPredicateType.and, subpredicates: subpredicates)
            query.sortDescriptors = [NSSortDescriptor(key: "position", ascending: false)]
            query.limit = limit
            query.offset = 0
            guard let messages = try layerClient?.execute(query).array as? [LYRMessage] else {
                return
            }
            
            var messagesArray = messages.map { message -> Message in
                Message(message )
            }
            messagesArray.reverse()
            completion(messagesArray, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return user != nil
    }
    
    public func layerClient(_ client: LYRClient, didReceiveAuthenticationChallengeWithNonce nonce: String) {
        
    }
    
    @objc public func didReceiveLayerObjectsDidChangeNotification(notification: Notification) {
        let changes : Array<LYRObjectChange> = notification.userInfo![AnyHashable(LYRClientObjectChangesUserInfoKey)] as! Array<LYRObjectChange>
        
        for change in changes {
            let changeKey = change.type
            let changeObject = change.object
            switch (changeKey) {
            case .create :
                if let message = changeObject as? LYRMessage {
                    self.conversations[message.conversation!.identifier]?.setNewMessage.onNext(Message(message))
                }
            case .update:
                if let identity = changeObject as? LYRIdentity {
                    if (identity.userID == user?.identity) {
                        user?.login.value = (identity.presenceStatus.rawValue == 1)
                    }
                }
                if let message = changeObject as? LYRMessage {
                    self.conversations[message.conversation!.identifier]?.setMessagesUpdated.onNext(())
                }
            case .delete:
                break
            }
        }
    }
    
    @objc public func didReciveTypingIndicator(notification: Notification) {
        let lyrConversation = notification.object! as! LYRConversation
        let typingIndicator = notification.userInfo![AnyHashable(LYRTypingIndicatorObjectUserInfoKey)] as! LYRTypingIndicator
        
        let conversation = self.conversations[lyrConversation.identifier]
        if(conversation != nil){
            switch typingIndicator.action {
            case .begin:
                conversation?.setStartTyping.onNext(User(typingIndicator.sender))
            case .pause, .finish:
                conversation?.setStopTyping.onNext(User(typingIndicator.sender))
            }
        }
    }
    
}
