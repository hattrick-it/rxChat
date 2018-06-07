//
//  ConversationViewCell.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/14/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit

class ConversationViewCell: UITableViewCell {
    
    static let nibName = "ConversationViewCell"
    static let cellReuseIdentifier = "ConversationViewCell"
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    
    func configure(with conversation: Conversation) {
        titleLabel.text = conversation.conversationName
        lastMessage.text = conversation.lastMessage?.body
    }
    
}
