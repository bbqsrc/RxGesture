//
//  RxSearchControllerDelegateProxy.swift
//  Rx
//
//  Created by Segii Shulga on 3/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
   
   import Foundation
#if !RX_NO_MODULE
   import RxSwift
#endif
   import UIKit

/**
 For more information take a look at `DelegateProxyType`.
 */
@available(iOS 8.0, *)
open class RxSearchControllerDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , UISearchControllerDelegate {
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    open class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let searchController: UISearchController = castOrFatalError(object)
        searchController.delegate = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    open class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let searchController: UISearchController = castOrFatalError(object)
        return searchController.delegate
    }
    
}
   
#endif
