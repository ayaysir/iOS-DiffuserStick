//
//  IAPHelper.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/28/24.
//

import StoreKit

public struct InAppProducts {
    private init() {}
    
    public static let productIDs = [
        "com.yoonbumtae.DiffuserStick.IAP.removeAds1"
    ]
    
    private static let productIdentifiers: Set<ProductIdentifier> = Set(productIDs)
    public static let helper = IAPHelper(productIds: InAppProducts.productIdentifiers)
}

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperErrorNotification = Notification.Name("IAPHelperErrorNotification")
}

open class IAPHelper: NSObject {
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("IAP: (Maybe previously purchased): \(productIdentifier)")
            } else {
                print("IAP: (Maybe not purchased): \(productIdentifier)")
            }
        }
        
        super.init()
        SKPaymentQueue.default().add(self) // App Store와 지불정보를 동기화하기 위한 Observer 추가
    }
}

extension IAPHelper {
    /// 앱스토어에서 결제된 인앱결제 상품들을 가져옵니다.
    public func inquireProductsRequest(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    /// 인앱결제 상품을 구입합니다.
    public func buyProduct(_ product: SKProduct) {
        print("IAP Buying: \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// 구입내역을 복원합니다.
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("IAP: Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("IAP - Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("IAP - Failed to load list of products.")
        print("IAP - Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                print("IAP Transaction: Deferred")
                break
            case .purchasing:
                print("IAP Transaction: Purchasing")
                break
            @unknown default:
                break
            }
        }
    }
    
    /// 구입 성공
    private func complete(transaction: SKPaymentTransaction) {
        print("IAP Transaction Purchase: complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// 복원 성공
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("IAP Transaction: restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// 구매 실패
    private func fail(transaction: SKPaymentTransaction) {
        print("IAP Transaction Purchase: fail...")
        
        if let transactionError = transaction.error as NSError? {
            print("IAP Transaction Error: \(transactionError.localizedDescription)")
        }
        
        deliverPurchaseErrorNotification()
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// 구매한 인앱 상품 키를 UserDefaults로 로컬에 저장
    /// - 실제로 구입 성공/복원된 경우에만 실행된다.
    private func deliverPurchaseNotificationFor(identifier: String?) {
        print(#function, identifier ?? "")
        guard let identifier = identifier else { return }

        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
    
    /// 실패시 보냄
    private func deliverPurchaseErrorNotification() {
        NotificationCenter.default.post(name: .IAPHelperErrorNotification, object: nil)
    }
}

extension IAPHelper {
    /// 구매이력 영수증 가져오기 - 검증용
    public func getReceiptData() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                return receiptString
            }
            catch {
                print("IAP - Couldn't read receipt data with error: " + error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
}

extension SKProduct {

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    var isFree: Bool {
        price == 0.00
    }

    var localizedPrice: String? {
        guard !isFree else {
            return nil
        }
        
        let formatter = SKProduct.formatter
        formatter.locale = priceLocale

        return formatter.string(from: price)
    }

}
