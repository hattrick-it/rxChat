//
//  HomeCoordinator.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/15/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class HomeCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        viewModel.selectedConversation.do(onNext: { [weak self] (conversation) in
            let viewModel = ConversationViewModel(conversation: conversation)
            let viewController = ConversationViewController(viewModel: viewModel)
            let navigationController = self?.window.rootViewController as? UINavigationController
            navigationController?.pushViewController(viewController, animated: true)
        }).subscribe().disposed(by: disposeBag)
        
        return viewModel.logout.filter { $0 }.map { _ in }.do(onNext: {
            self.window.rootViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
}
