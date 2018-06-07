//
//  CustomMessageContainerView.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/30/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import MessageKit
import UIKit

open class CustomMessageContainerView: UICollectionViewCell{
    
    var messageContainerView = MessageContainerView()
    
    func configure() {
        self.addSubview(messageContainerView)
        messageContainerView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
    }
    
    func setupShadowAndCorner() {
        let shadowPath2 = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: CGFloat(0.0), height: CGFloat(5.0))
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.shadowPath = shadowPath2.cgPath
    }
    
}
