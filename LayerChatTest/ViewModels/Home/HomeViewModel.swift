//
//  HomeViewModel.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/14/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel {
    
    let disposeBag = DisposeBag()
    
    // MARK: - Vars
    
    var conversations = Variable<[Conversation]>([])
    
    // MARK: - Inputs
    
    var getConversations: AnyObserver<Void> {
        return _conversations.asObserver()
    }
    
    var selectConversations: AnyObserver<Conversation> {
        return _selectedConversation.asObserver()
    }
    
    var tryLogout: AnyObserver<Void> {
        return _logout.asObserver()
    }
    
    // MARK: - Outputs
    
    var logout: Observable<Bool> {
        return _logout.asObservable().flatMap({ _ in
            ChatManager.sharedInstance().rx.deauthenticate()
        })
    }
    
    var selectedConversation: Observable<Conversation> {
        return _selectedConversation.asObservable()
    }
    
    // MARK: - Private vars
    
    private let _conversations = PublishSubject<Void>()
    private let _logout = PublishSubject<Void>()
    private let _selectedConversation = PublishSubject<Conversation>()
    
    init () {
        _conversations.asObservable().flatMap { _ in
            ChatManager.sharedInstance().rx.conversations
        }.bind(to: conversations).disposed(by: disposeBag)
    }
    
    // MARK: - Public functions
    
    func newConversation(participants: [String]) -> Single<Conversation> {
        return ChatManager.sharedInstance().rx.newConversation(participants: participants)
    }
    
}
