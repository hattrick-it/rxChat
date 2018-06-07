//
//  CustomCell.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/29/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import MessageKit

open class CustomCell: MessageCollectionViewCell {
    
    private let gradientStartColor = UIColor(red: 46/255, green: 132/255, blue: 250/255, alpha: 1)
    private let gradientEndColor = UIColor(red: 83/255, green: 99/255, blue: 236/255, alpha: 1)
    private var gradientBackgroundLayer: CAGradientLayer?
    
    /// The image view displaying the avatar.
    open var avatarView = AvatarView()
    
    /// The container used for styling and holding the message's content view.
    open var messageContainerView: CustomMessageContainerView = {
        let containerView = CustomMessageContainerView()
        containerView.messageContainerView.clipsToBounds = true
        containerView.messageContainerView.layer.masksToBounds = true
        return containerView
    }()
    
    /// The label used to display the message's text.
    open var messageLabel = MessageLabel()
    
    /// The top label of the cell.
    open var cellTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// The top label of the messageBubble.
    open var messageTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()
    
    /// The bottom label of the messageBubble.
    open var messageBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()
    
    /// The `MessageCellDelegate` for the cell.
    open weak var delegate: MessageCellDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupSubviews() {
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(messageContainerView)
        messageContainerView.messageContainerView.addSubview(messageLabel)
        contentView.addSubview(messageTopLabel)
        contentView.addSubview(messageBottomLabel)
        contentView.addSubview(avatarView)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        messageTopLabel.text = nil
        messageBottomLabel.text = nil
    }
    
    // MARK: - Configuration
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        // Call this before other laying out other subviews
        layoutMessageContainerView(with: attributes)
        layoutMessageLabel(with: attributes)
        layoutBottomLabel(with: attributes)
        layoutCellTopLabel(with: attributes)
        layoutMessageTopLabel(with: attributes)
        layoutAvatarView(with: attributes)
    }
    
    /// Used to configure the cell.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` this cell displays.
    ///   - indexPath: The `IndexPath` for this cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell is contained.
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            return
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            return
        }
        
        switch message.kind {
        case .custom(let text):
            let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
            messageLabel.text = text as? String
            messageLabel.textColor = textColor
        default:
            break
        }
        
        delegate = messagesCollectionView.messageCellDelegate
        
        let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)
        
        displayDelegate.configureAvatarView(avatarView, for: message, at: indexPath, in: messagesCollectionView)
        
        messageContainerView.messageContainerView.backgroundColor = messageColor
        messageContainerView.messageContainerView.style = messageStyle
        
        let topCellLabelText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        let bottomText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)
        
        cellTopLabel.attributedText = topCellLabelText
        messageTopLabel.attributedText = topMessageLabelText
        messageBottomLabel.attributedText = bottomText
        
        messageBottomLabel.textColor = dataSource.isFromCurrentSender(message: message) ? .white : .gray
        messageBottomLabel.adjustsFontSizeToFitWidth = true
        messageTopLabel.textColor = dataSource.isFromCurrentSender(message: message) ? .white : .gray
        
        setupGradientBackground(dataSource.isFromCurrentSender(message: message))
        if(!dataSource.isFromCurrentSender(message: message)) {
            messageContainerView.setupShadowAndCorner()
        }
    }
    
    /// Handle tap gesture on contentView and its subviews.
    open func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        
        switch true {
        case messageContainerView.messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView.messageContainerView)):
            delegate?.didTapMessage(in: self)
        case avatarView.frame.contains(touchLocation):
            delegate?.didTapAvatar(in: self)
        case cellTopLabel.frame.contains(touchLocation):
            delegate?.didTapCellTopLabel(in: self)
        case messageTopLabel.frame.contains(touchLocation):
            delegate?.didTapMessageTopLabel(in: self)
        case messageBottomLabel.frame.contains(touchLocation):
            delegate?.didTapMessageBottomLabel(in: self)
        case messageLabel.frame.contains(touchLocation):
            delegate?.didTapMessage(in: self)
        default:
            break
        }
    }
    
    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return messageContainerView.messageContainerView.frame.contains(touchPoint)
    }
    
    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    open func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }
    
    // MARK: - Origin Calculations
    
    /// Positions the cell's `AvatarView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
        guard attributes.avatarSize != .zero else { return }
        
        var origin: CGPoint = .zero
        
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            break
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width
        case .natural:
            break
        }
        
        switch attributes.avatarPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
            if(attributes.cellTopLabelSize != .zero) {
                origin.y += attributes.cellTopLabelSize.height
            }
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.messageContainerView.frame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.messageContainerView.frame.maxY - attributes.avatarSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.messageContainerView.frame.midY - (attributes.avatarSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.avatarSize.height
        default:
            break
        }
        
        avatarView.backgroundColor = .black
        avatarView.frame.origin = origin
    }
        
    /// Positions the cell's `MessageContainerView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        guard attributes.messageContainerSize != .zero else { return }
        
        var origin: CGPoint = .zero
        
        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.messageBottomLabelSize.height - attributes.messageContainerSize.height - attributes.messageContainerPadding.top
        case .messageCenter:
            if attributes.avatarSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.messageContainerPadding.top
        }
        
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right
        case .natural:
            break
        }
        
        let width = attributes.messageContainerSize.width
        let height = attributes.messageContainerSize.height + attributes.messageTopLabelSize.height + attributes.messageBottomLabelSize.height
        let size = CGSize(width: width, height: height)
        
        messageContainerView.frame = CGRect(origin: origin, size: size)
        messageContainerView.configure()
    }
    
    /// Positions the cell's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        guard attributes.cellTopLabelSize != .zero else { return }
        
        cellTopLabel.frame = CGRect(origin: .zero, size: attributes.cellTopLabelSize)
    }
    
    /// Positions the message bubble's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        guard attributes.messageTopLabelSize != .zero else { return }
        
        messageTopLabel.textAlignment = attributes.messageTopLabelAlignment.textAlignment
        messageTopLabel.textInsets = attributes.messageTopLabelAlignment.textInsets
        
        let y = messageContainerView.messageContainerView.frame.minY
        let origin = CGPoint(x: 0, y: y)
        
        messageTopLabel.frame = CGRect(origin: origin, size: attributes.messageTopLabelSize)
    }
    
    /// Positions the cell's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        guard attributes.messageBottomLabelSize != .zero else { return }
        
        messageBottomLabel.textAlignment = attributes.messageBottomLabelAlignment.textAlignment
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets
        
        var y = messageContainerView.messageContainerView.frame.maxY - attributes.messageBottomLabelSize.height
        if(attributes.cellTopLabelSize != .zero) {
            y += attributes.cellTopLabelSize.height
        }
        let x = messageContainerView.frame.origin.x
        let origin = CGPoint(x: x, y: y)
        
        let width = messageContainerView.frame.width
        let height = attributes.messageBottomLabelSize.height
        let size = CGSize(width: width, height: height)
        
        messageBottomLabel.frame = CGRect(origin: origin, size: size)
    }
    
    open func layoutMessageLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageLabel.textInsets = attributes.messageLabelInsets
        
        let width = messageContainerView.messageContainerView.bounds.width
        let height = messageContainerView.messageContainerView.bounds.height - attributes.messageTopLabelSize.height - attributes.messageBottomLabelSize.height
        let size = CGSize(width: width, height: height)
        
        let x = messageContainerView.messageContainerView.bounds.origin.x
        let y = messageContainerView.messageContainerView.bounds.origin.y + attributes.messageTopLabelSize.height
        let origin = CGPoint(x: x, y: y)
        
        messageLabel.frame = CGRect(origin: origin, size: size)
    }
    
    private func setupGradientBackground(_ isSender: Bool) {
        let prevGradientBackgroundLayer = gradientBackgroundLayer
        
        if(isSender) {
            gradientBackgroundLayer = CAGradientLayer()
            gradientBackgroundLayer?.frame = messageContainerView.messageContainerView.bounds
            gradientBackgroundLayer?.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
            gradientBackgroundLayer?.locations = [0, 1]
            gradientBackgroundLayer?.startPoint = CGPoint(x: 0, y: 1)
            gradientBackgroundLayer?.endPoint = CGPoint(x: 1, y: 1)
            if(prevGradientBackgroundLayer == nil) {
                messageContainerView.messageContainerView.layer.insertSublayer(gradientBackgroundLayer!, at: 0)
            }else {
                messageContainerView.messageContainerView.layer.replaceSublayer(prevGradientBackgroundLayer!, with: gradientBackgroundLayer!)
            }
        }else{
            prevGradientBackgroundLayer?.removeFromSuperlayer()
            gradientBackgroundLayer = nil
        }
        messageContainerView.messageContainerView.layer.masksToBounds = true
    }
    
}
