//
//  Message.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/14/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import LayerKit

public enum MessageRecipientStatus: Int {
    case invalid = -1
    case pending = 0
    case sent = 1
    case delivered = 2
    case read = 3
    
    public func toString() -> String {
        switch self {
        case .invalid:
            return "Invalid"
        case .pending:
            return "Pending"
        case .sent:
            return "Sent"
        case .delivered:
            return "Delivered"
        case .read:
            return "Read"
        }
    }
}

public class Message: NSObject {
    
    // MARK: - Vars
    
    private var message: LYRMessage
    
    // MARK: - Public vars
    
    public var originalMessage: LYRMessage {
        return message
    }
    
    public var identity: String {
        return message.identifier.absoluteString
    }
    
    public var body: String {
        return (String(data: (message.parts.first?.data!)!, encoding: String.Encoding.utf8))!
    }
    
    public var user: User {
        return User(message.sender)
    }
    
    public var date: Date {
        return message.receivedAt!
    }
    
    public var status: MessageRecipientStatus {
        var status = MessageRecipientStatus.read
        if(message.recipientStatusByUserID != nil) {
            for recipientStatus in message.recipientStatusByUserID! {
                if(recipientStatus.value.intValue < status.rawValue) {
                    status = MessageRecipientStatus(rawValue: recipientStatus.value.intValue)!
                }
            }
        }
        return status
    }
    
    public required init(_ message: LYRMessage) {
        self.message = message
        
        super.init()
    }
    
    // MARK: - Public functions
    
    public func gatRecipientStatus(forUser user: User) -> MessageRecipientStatus {
        return MessageRecipientStatus(rawValue: message.recipientStatus(forUserID: user.identity).rawValue)!
    }
    
    public func markAsRead() {
        do {
            try message.markAsRead()
        } catch { }
    }
    
}
