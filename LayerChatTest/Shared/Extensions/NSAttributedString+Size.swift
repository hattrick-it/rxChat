//
//  NSAttributedString+Size.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/30/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    func labelSize(considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        
        return rect.size
    }
    
}
