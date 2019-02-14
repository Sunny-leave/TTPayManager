//
//  PayManager.h
//  SwiftToutiao
//
//  Created by 刘威 on 2018/12/6.
//  Copyright © 2018 votee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PayManagerModel;

typedef void (^PayManagerBlock)(PayManagerModel *payModel);

@interface PayManagerModel : NSObject

@property (nonatomic,   copy) NSString *appStoreReceipt;        ///二进制数据
@property (nonatomic,   copy) NSString *applicationUsername;    ///orderId
@property (nonatomic,   copy) NSString *productIdentifier;      ///goodsID
@property (nonatomic,   copy) NSString *transactionIdentifier;  ///当前交易id
//@property (nonatomic,   copy) NSString *orderId;                ///orderid
//@property (nonatomic,   copy) NSString *productId;              ///本地产品id
//@property (nonatomic,   copy) NSDecimalNumber *price;           ///交易价格
@property (nonatomic, strong) SKPaymentTransaction *transaction;///与苹果之间的事物
@property (nonatomic, strong) NSDictionary *errorUserInfo;       ///错误信息


@property (nonatomic,   copy) NSString *msg;                    ///当前交易提示文案
@property (nonatomic, assign) NSInteger code;                   ///当前交易状态

@end


@interface PayManager : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>


@property (strong, nonatomic, readonly) NSArray<SKPaymentTransaction *> *transactions;
@property (copy  , nonatomic, readonly) NSString *appStoreReceipt;

/**
 *  单例
 *
 *  @return 实例化类
 */
+ (instancetype)shareManager;


/**
 *  处理未完成的订单监听
 *
 *  @block 方法回调
 */
- (void)setManagerWithBlock:(PayManagerBlock)block;

/**
 *  购买操作
 *
 *  @goodsId 苹果商品预设id
 *  @orderId 本地服务器交易之前创建的订单号
 */
- (void)productWithGoodsId:(NSString *)goodsId
                 productId:(NSString *)productId
                   orderId:(NSString *)orderId
                    userId:(NSInteger)userId
                     block:(PayManagerBlock)block;

/**
 *  拉取操作
 *
 *  @goodsIdArray 苹果商品预设id
 */
- (void)requestRresponseWithGoodsIdArray:(NSArray *)goodsIdArray;

@end

NS_ASSUME_NONNULL_END
