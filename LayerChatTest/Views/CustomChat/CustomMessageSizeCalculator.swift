//
//  CustomMessageSizeCalculator.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/29/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import MessageKit
import UIKit

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    public var incomingMessageLabelInsets = UIEdgeInsets(top: 5, left: 14, bottom: 1, right: 14)
    public var outgoingMessageLabelInsets = UIEdgeInsets(top: 5, left: 14, bottom: 1, right: 14)
    
    public var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    private var messageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    internal func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }
    
    open override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = messageLabelInsets(for: message)
        return maxWidth - (textInsets.left + textInsets.right)
    }
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        
        switch message.kind {
        case .attributedText(let text):
            attributedText = text
        case .custom(let text):
            attributedText = NSAttributedString(string: text as! String, attributes: [.font: messageLabelFont])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        
        messageContainerSize = attributedText.labelSize(considering: maxWidth)
        messageInsets = messageLabelInsets(for: message)
        
        messageContainerSize.width += (messageInsets.right + messageInsets.left)
        messageContainerSize.height += (messageInsets.top + messageInsets.bottom)
        
        return messageContainerSize
    }
    
    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
        
        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        
        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont
        
        let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        let bottomText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)
        
        
        let bottomWidht = (bottomText?.labelSize(considering: 100).width ?? 0) + (messageInsets.right + messageInsets.left)
        let topWidht = (topMessageLabelText?.labelSize(considering: 100).width ?? 0) + (messageInsets.right + messageInsets.left)
        
        attributes.messageContainerSize.width = max(attributes.messageContainerSize.width, bottomWidht, topWidht)
    }
    
}
