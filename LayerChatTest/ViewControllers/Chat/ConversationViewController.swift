//
//  ConversationViewController.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/16/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MessageKit
import SwiftDate

var hourFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter
}()

var dateFormatter: DateFormatter = {
   let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()



class ConversationViewController: MessagesViewController {
    
    let refreshControl = UIRefreshControl()
    
    var viewModel: ConversationViewModel
    let disposeBag = DisposeBag()
    
    var messagesUI: [MessageUI] = []
    
    // MARK: - Lifecycle methods
    
    init(viewModel: ConversationViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupCollectionView()
        super.viewDidLoad()
        
        setupNavigationBar()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getMessages.onNext(())
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigationBar() {
        let topText = NSLocalizedString(viewModel.conversation.conversationName, comment: "")
        let bottomText = NSLocalizedString("key", comment: "")
        
        let titleParameters = [NSAttributedStringKey.foregroundColor : UIColor.black,
                               NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20)]
        let subtitleParameters = [NSAttributedStringKey.foregroundColor  : UIColor.gray,
                                  NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
        
        let title:NSMutableAttributedString = NSMutableAttributedString(string: topText, attributes: titleParameters)
        let subtitle:NSAttributedString = NSAttributedString(string: bottomText, attributes: subtitleParameters)
        
        title.append(NSAttributedString(string: "\n"))
        title.append(subtitle)
        
        let size = title.size()
        
        let width = size.width
        guard let height = navigationController?.navigationBar.frame.size.height else {return}
        
        let titleLabel = UILabel(frame: CGRect(x: 0,y: 0, width: width, height: height))
        titleLabel.attributedText = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        
        let titleButton = UIBarButtonItem(customView: titleLabel)
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBar-backChevron"), style: .plain, target: nil, action: #selector(ConversationViewController.backButtonBar))
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.leftBarButtonItems = [backButtonItem, titleButton]
    }
    
    fileprivate func setupCollectionView() {
        let layout = CustomMessagesFlowLayout()
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: layout)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.register(CustomCell.self)
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(ConversationViewController.loadMoreMessages), for: .valueChanged)
        
        layout.customMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.customMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        layout.customMessageSizeCalculator.incomingAvatarSize = CGSize(width: 40, height: 40)
        layout.customMessageSizeCalculator.incomingAvatarPosition = AvatarPosition(vertical: .messageLabelTop)
        layout.customMessageSizeCalculator.incomingMessageBottomLabelAlignment.textAlignment = .right
        layout.customMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 10)
        
        self.customMessageInputBar()
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    func customMessageInputBar() {
        defaultStyle()
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.inputTextView.placeholder = "Type a message..."
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        messageInputBar.inputTextView.layer.cornerRadius = 15.0
        messageInputBar.textViewPadding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let notesButton = InputBarButtonItem().configure {
            $0.setSize(CGSize(width: 60, height: 30), animated: true)
            $0.title = "Notes"
            $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
            $0.backgroundColor = .gray
            $0.layer.cornerRadius = 15
            $0.setTitleColor(.white, for: UIControlState.normal)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
        messageInputBar.sendButton.configure {
            $0.image = UIImage(named: "SendButton")
            $0.title = nil
        }
        messageInputBar.setRightStackViewWidthConstant(to: 30, animated: true)
        messageInputBar.setLeftStackViewWidthConstant(to: 60, animated: true)
        messageInputBar.setStackViewItems([notesButton], forStack: .left, animated: false)
        
        messageInputBar.inputTextView.rx.text
            .orEmpty
            .bind(to: viewModel.message)
            .disposed(by: disposeBag)
        
        messageInputBar.sendButton.rx.tap
            .bind(to: viewModel.sendMessage)
            .disposed(by: disposeBag)
    }
    
    fileprivate func setupBindings() {
        
        viewModel.messages
            .map { messages -> [MessageUI] in
                messages.map{ message -> MessageUI in
                    MessageUI(message: message)
                }
            }.subscribe(onNext: { messages in
                self.messagesUI = messages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }).disposed(by: disposeBag)
        
        viewModel.previousMessages
            .map{ messages -> [MessageUI] in
                messages.map { message -> MessageUI in
                    MessageUI(message: message)
                }
            }.subscribe(onNext: { messages in
                self.messagesUI.insert(contentsOf: messages, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
        
        viewModel.newMessage
            .map{ message -> MessageUI in
                MessageUI(message: message)
            }.subscribe(onNext: { message in
                self.messagesUI.append(message)
                self.messagesCollectionView.insertSections([self.messagesUI.count - 1])
                self.messagesCollectionView.scrollToBottom()
            }).disposed(by: disposeBag)
        
        viewModel.sentMessage
            .subscribe(onNext: { success in
                self.messageInputBar.inputTextView.text = String()
                if(!success) {
                    self.showAlert(withTitle: "Error to send message", message: "Try again later.", buttonTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        viewModel.typing.asObservable()
            .subscribe(onNext: { user in
                self.showIsTypingIndicator(forUser: user)
            }).disposed(by: disposeBag)
        
        viewModel.messagesUpdated
            .subscribe(onNext: { _ in
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }).disposed(by: disposeBag)
        
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - Button calls
    
    @objc func loadMoreMessages() {
        self.viewModel.getPreviousMessages.onNext((self.messagesUI.first?.message)!)
    }
    
    @objc func backButtonBar() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func showIsTypingIndicator(forUser user: User?) {
        if user == nil {
            self.messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
            self.messageInputBar.topStackViewPadding = .zero
        } else {
            let label = UILabel()
            label.text = user!.displayName + " is typing..."
            label.font = UIFont.boldSystemFont(ofSize: 16)
            self.messageInputBar.topStackView.addArrangedSubview(label)
            self.messageInputBar.topStackViewPadding.top = 6
            self.messageInputBar.topStackViewPadding.left = 12
            
            // The backgroundView doesn't include the topStackView. This is so things in the topStackView can have transparent backgrounds if you need it that way or another color all together
            self.messageInputBar.backgroundColor = self.messageInputBar.backgroundView.backgroundColor
        }
    }
}


// MARK: - MessagesDataSource

extension ConversationViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: (ChatManager.sharedInstance().user?.identity)!, displayName: (ChatManager.sharedInstance().user?.displayName)!)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesUI.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesUI[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let prevMessage = indexPath.section > 0 ? self.messagesUI[indexPath.section - 1] : nil
        if(prevMessage == nil || !(prevMessage!.sentDate.isInSameDayOf(date: message.sentDate))) {
          return NSAttributedString(string: dateFormatter.string(from: message.sentDate), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let bottomString = hourFormatter.string(from: message.sentDate) + " "
        let attributedText = NSMutableAttributedString(string: bottomString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
        if(isFromCurrentSender(message: message)){
            let messageUI = message as! MessageUI
            let attachment:NSTextAttachment = NSTextAttachment()
            switch messageUI.message.status {
            case .sent:
                attachment.image = UIImage(named: "OneTick")
                attributedText.append(NSAttributedString(attachment: attachment))
            case .delivered:
                attachment.image = UIImage(named: "DoubleTick")
                attributedText.append(NSAttributedString(attachment: attachment))
            case .read:
                attachment.image = UIImage(named: "DoubleTickColor")
                attributedText.append(NSAttributedString(attachment: attachment))
            default:
                break
            }
        }
        return attributedText
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .white
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return   .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if(!isFromCurrentSender(message: message)) {
            let prevMessage = indexPath.section > 0 ? self.messagesUI[indexPath.section - 1] : nil
            if(prevMessage == nil || prevMessage!.sender != message.sender) {
                avatarView.frame.size = CGSize(width: 40, height: 40)
                let avatar = Avatar(initials: (message.sender.displayName.first?.description)!)
                avatarView.set(avatar: avatar)
            } else {
                avatarView.frame = .zero
            }
        } else {
            avatarView.frame = .zero
        }
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let prevMessage = indexPath.section > 0 ? self.messagesUI[indexPath.section - 1] : nil
        if(prevMessage == nil || !(prevMessage!.sentDate.isInSameDayOf(date: message.sentDate))) {
            return 15
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
}

// MARK: - MessageCellDelegate

extension ConversationViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ConversationViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}
