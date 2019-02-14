//
//  PayManager.m
//  SwiftToutiao
//
//  Created by 刘威 on 2018/12/6.
//  Copyright © 2018 votee. All rights reserved.
//

#import "PayManager.h"

@interface PayManager ()

@property (nonatomic,   copy) PayManagerBlock payBlock;
@property (nonatomic,   copy) PayManagerBlock managerBlock;
@property (nonatomic, strong) SKProductsResponse *respones;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) NSArray *goodsIdArray;

@end

@implementation PayManager {
//    NSInteger _userId;
    NSString *_goodsId;
    NSString *_orderId;
    NSString *_productId;
//    NSDecimalNumber *_price;
}

+ (instancetype)shareManager {
    static dispatch_once_t once;
    static PayManager *manager = nil;
    dispatch_once(&once, ^{
        manager = [[PayManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSArray<SKPaymentTransaction *> *)transactions {
    return [SKPaymentQueue defaultQueue].transactions;
}

- (NSString *)appStoreReceipt {
    // appStoreReceiptURL iOS7.0增加的，购买充值完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (!encodeStr) {
        encodeStr = @"";
    }
    return encodeStr;
}

- (void)setManagerWithBlock:(PayManagerBlock)block {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    _managerBlock = block;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)requestRresponseWithGoodsIdArray:(NSArray *)goodsIdArray {
    _goodsIdArray = goodsIdArray;
    if ([SKPaymentQueue canMakePayments]) {
        if (_request) {
            [_request cancel];
        }
        NSSet *set = [NSSet setWithArray:goodsIdArray];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        _request = request;
        [request start];
    } else {
        NSLog(@"不允许内购");
    }
}



- (void)productWithGoodsId:(NSString *)goodsId
                 productId:(NSString *)productId
                   orderId:(NSString *)orderId
                    userId:(NSInteger)userId
                     block:(PayManagerBlock)block {
    
    
    if ([SKPaymentQueue canMakePayments]) {
        _goodsId = goodsId;
        _orderId = orderId;
        _payBlock = block;
//        _userId = userId;
        _productId = productId;
        
        if (_respones) {
            SKProduct *requestProduct = nil;
            for (SKProduct *pro in _respones.products) {
                if([pro.productIdentifier isEqualToString:_goodsId]){
                    requestProduct = pro;
//                    _price = [pro price];
                }
            }
            
            if (requestProduct) {
                [self pay:requestProduct];
            } else {
                NSLog(@"充值失败");
                if (_payBlock) {
                    PayManagerModel *model = [[PayManagerModel alloc] init];
                    model.msg = @"充值失败";
                    model.code = 2;
                    _payBlock(model);
                }
            }
        } else {
            if (_request) {
                [_request cancel];
            }
            NSSet *set = [NSSet setWithArray:_goodsIdArray];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
            request.delegate = self;
            _request = request;
            [request start];
        }
    } else {
        NSLog(@"不允许内购");
    }
}

    ///成功回调
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    if ([response.products count] == 0) {
        NSLog(@"没有该商品");
        return;
    }
    
    if (!_respones) {
        if (!_goodsId) {
            _respones = response;
            return;
        }
        SKProduct *requestProduct = nil;
        for (SKProduct *pro in response.products) {
            if([pro.productIdentifier isEqualToString:_goodsId]){
                requestProduct = pro;
//                _price = [pro price];
            }
        }
        
        if (requestProduct) {
            [self pay:requestProduct];
        } else {
            NSLog(@"充值失败");
            if (_payBlock) {
                PayManagerModel *model = [[PayManagerModel alloc] init];
                model.msg = @"充值失败";
                model.code = 2;
                _payBlock(model);
            }
        }
    }
    _respones = response;
}

///失败的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    if (error && error.userInfo[@"NSLocalizedDescription"]) {
        if (_payBlock) {
            PayManagerModel *model = [[PayManagerModel alloc] init];
            model.msg = error.userInfo[@"NSLocalizedDescription"];
            model.code = 2;
            _payBlock(model);
        }
    }
}
///
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"%@",request);
}

- (void)pay:(SKProduct *)product {
    SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = _orderId; //[NSString stringWithFormat:@"%ld",(long)_userId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - paymentQueue
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (int i=0; i<transactions.count; i++) {
        SKPaymentTransaction *transaction = transactions[i];
        NSLog(@"%ld",(long)transaction.transactionState);
        switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchased://充值完成
                [self completeTransaction:transaction];
                break;
                case SKPaymentTransactionStateFailed://充值失败
                [self failedTransaction:transaction];
                break;
                case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
                case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"商品添加进列表");
                break;
            default:
                [self failedTransaction:transaction];
                break;
        }
    }
}

#pragma mark - callback - method
- (void)completeTransaction:(SKPaymentTransaction *)transaction {

    
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    
    PayManagerModel *model = [[PayManagerModel alloc] init];
    model.appStoreReceipt = [self appStoreReceipt];
    model.applicationUsername = transaction.payment.applicationUsername.length?transaction.payment.applicationUsername:@"";
    model.productIdentifier = transaction.payment.productIdentifier.length?transaction.payment.productIdentifier:@"";
    model.transactionIdentifier = transaction.transactionIdentifier.length?transaction.transactionIdentifier:@"";
    model.msg = @"充值成功";
    model.code = 1;
    model.errorUserInfo = transaction.error.userInfo?transaction.error.userInfo:@{};
    model.transaction = transaction;
    
    if (_payBlock) {
        _payBlock(model);
    } else if (_managerBlock) {
        _managerBlock(model);
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (_payBlock) {
        PayManagerModel *model = [[PayManagerModel alloc] init];
//        model.msg = transaction.error.userInfo.allValues[0];
        model.errorUserInfo = transaction.error.userInfo;
        model.msg = @"充值失败";
        switch (transaction.error.code) {
            case SKErrorPaymentCancelled: {
                model.msg = @"取消购买";
                model.code = 2;
            }
                break;
            default: {
                model.code = 0;
                NSLog(@"SKErrorUnknown");
                //            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
        }
        
        model.appStoreReceipt = [self appStoreReceipt];
        model.applicationUsername = transaction.payment.applicationUsername.length?transaction.payment.applicationUsername:@"";
        model.productIdentifier = transaction.payment.productIdentifier.length?transaction.payment.productIdentifier:@"";
        model.transactionIdentifier = transaction.transactionIdentifier.length?transaction.transactionIdentifier:@"";
        model.errorUserInfo = transaction.error.userInfo?transaction.error.userInfo:@{};
        model.transaction = transaction;
        
        _payBlock(model);
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (_payBlock) {
        PayManagerModel *model = [[PayManagerModel alloc] init];
        model.msg = @"重复充值";
        model.code = 2;
        _payBlock(model);
    }
}

@end


@implementation PayManagerModel
@end
