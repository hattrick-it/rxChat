//
//  MessageUI.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/18/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import MessageKit

public class MessageUI: MessageType {
    
    public var messageId: String
    public var sender: Sender
    public var sentDate: Date
    public var kind: MessageKind
    
    var message: Message
    
    
    private init(message: Message, kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.message = message
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    convenience init (message: Message) {
        self.init(message: message, kind: .custom(message.body), sender: Sender(id: message.user.identity, displayName: message.user.displayName), messageId: message.identity, date: message.date)
    }
    
}
