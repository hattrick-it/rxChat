//
//  HomeViewController.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/14/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var conversationsTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var add: UIBarButtonItem?
    var logout: UIBarButtonItem?
    
    // MARK: Lifecycle methods
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigation()
        setupBindings()
    }
    
    // MARK: Private methods
    
    fileprivate func setupNavigation() {
        self.add = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        self.logout = UIBarButtonItem(title: "logout", style: .plain, target: nil, action: nil)
        navigationItem.setRightBarButton(add, animated: true)
        navigationItem.setLeftBarButton(logout, animated: true)
    }
    
    fileprivate func setupTableView() {
        conversationsTableView.tableFooterView = UIView()
        conversationsTableView.register(UINib(nibName: ConversationViewCell.nibName, bundle: nil), forCellReuseIdentifier: ConversationViewCell.cellReuseIdentifier)
    }
    
    fileprivate func setupBindings() {
        emptyLabel.isHidden = true
        viewModel.conversations.asObservable()
            .filter {
                $0.count != 0
            }.bind(to: conversationsTableView.rx.items(cellIdentifier: ConversationViewCell.cellReuseIdentifier, cellType: ConversationViewCell.self)) { (row, conversation, cell) in
                cell.configure(with: conversation)
            }.disposed(by: disposeBag)
        
        viewModel.conversations.asObservable().subscribe(onNext: { [weak self] conversations in
                guard let strongSelf = self else {
                    return
                }
            
                strongSelf.emptyLabel.isHidden = (conversations.count != 0)
            }).disposed(by: disposeBag)
        
        viewModel.getConversations.onNext(())
        
        conversationsTableView.rx.modelSelected(Conversation.self)
            .bind( to: viewModel.selectConversations )
            .disposed(by: disposeBag)
        
        add?.rx.tap
            .flatMap { [weak self] _ -> Observable<Conversation> in
                guard let strongSelf = self else {
                    return Observable.never()
                }
                
                return strongSelf.viewModel.newConversation(participants: ["558d3384-b3a4-4a92-8715-d1dc111d9e4b"]).asObservable()
            }.subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.viewModel.getConversations.onNext(())
            }).disposed(by: disposeBag)
        
        logout?.rx.tap
            .bind(to: viewModel.tryLogout)
            .disposed(by: disposeBag)
    }
    
}

