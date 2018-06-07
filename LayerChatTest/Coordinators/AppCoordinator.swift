//
//  AppCoordinator.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        if(ChatManager.sharedInstance().isUserLoggedIn()) {
            showHome()
        }else {
            showLogin()
        }
        return Observable.never()
    }
    
    // MARK: - Private methods
    
    private func showHome() {
        let homeCoordinator = HomeCoordinator(window: self.window)
        _ = self.coordinate(to: homeCoordinator).observeOn(MainScheduler.instance).do(onNext: { (_) in
            self.showLogin()
        }).subscribe().disposed(by: disposeBag)
    }
    
    private func showLogin() {
        let loginCoordinator = LoginCoordinator(window: window)
        _ = coordinate(to: loginCoordinator).observeOn(MainScheduler.instance).do(onNext: { (_) in
            self.showHome()
        }).subscribe().disposed(by: disposeBag)
    }
    
}
