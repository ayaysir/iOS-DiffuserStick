//
//  AdManager.swift
//  DiffuserStick
//
//  Created by 윤범태 on 3/1/24.
//

import Foundation

struct AdManager {
    static let `default` = AdManager()
    private init() {}
    
    var isPurchasedAdRemove: Bool {
        InAppProducts.helper.isProductPurchased(InAppProducts.productIDs.first!)
    }
    
    var isReallyShowAd: Bool {
        guard let isShowAd = Bundle.main.object(forInfoDictionaryKey: "ShowAd") as? Bool else {
            return false
        }
         
        return isShowAd && !isPurchasedAdRemove
    }
}
