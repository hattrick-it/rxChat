//
//  RequestHelper.swift
//  LayerChatTest
//
//  Created by Esteban Arrua on 5/10/18.
//  Copyright © 2018 Esteban Arrua. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import RxSwift

typealias Endpoint = AuthenticationService

class RequestHelper {
    
    let disposeBag = DisposeBag()
    
    // MARK: - Singleton
    fileprivate static let instance = RequestHelper()
    
    class func sharedInstance() -> RequestHelper {
        return instance
    }
    
    fileprivate var provider: MoyaProvider<AuthenticationService>
    
    init(){
        provider = MoyaProvider<AuthenticationService>()
    }
    
    
    func performRequest<T: Mappable>(endopoint: Endpoint, jsonEncoding: Bool = true) -> Observable<Result<T>> {
        return provider.rx.request(endopoint).map { response -> Result<T> in
            Result(json: JSON(response.data))
            }.asObservable()
    }
    
}
