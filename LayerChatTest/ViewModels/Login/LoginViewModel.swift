//
//  LoginViewModel.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let email = Variable<String>("")
    let password = Variable<String>("")
    
    // MARK: - Inputs
    
    let tryLogin: AnyObserver<Void>
    
    // MARK: - Outputs
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(self.email.asObservable(), self.password.asObservable()) {
            (user, password) in
            return user.count > 0 && password.count > 0
        }
    }
    
    var didLogin: Observable<Void> {
        return _didLogin.asObservable().filter{ $0 }.map{ _ in () }
    }
    
    var errorMessage: Observable<String> {
        return _errorMessage.asObservable()
    }
    
    // MARK: - Private Publish Subjects
    
    fileprivate let _didLogin = PublishSubject<Bool>()
    fileprivate let _errorMessage = PublishSubject<String>()
    
    init() {
        let _tryLogin = PublishSubject<Void>()
        tryLogin = _tryLogin.asObserver()
        
        let signIn = _tryLogin.asObservable().flatMap { [weak self] _ ->  Single<Result<User>> in
            guard let strongSelf = self else {
                return Single.never()
            }
            
            return ChatManager.sharedInstance().rx.authenticate(email: strongSelf.email.value, pass: strongSelf.password.value)
        }.share()
        
        signIn
            .filter{ $0.isSuccessful }
            .flatMap{ result -> Observable<Bool> in result.successValue!.login.asObservable() }
            .bind(to: _didLogin.asObserver())
            .disposed(by: disposeBag)
        
        signIn
            .filter { $0.isError }
            .map { result -> String in result.errorValue!.localizedDescription }
            .bind (to: _errorMessage.asObserver())
            .disposed(by: disposeBag)
    }
    
}
