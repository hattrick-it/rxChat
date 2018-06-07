//
//  CustomCellLayout.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/29/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import MessageKit

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    
    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
