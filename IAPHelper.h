//
//  IAPHelper.h
//  In-App-Purchase demo
//
//  Created by liman on 15-2-26.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>


@class IAPHelper;
@protocol IAPHelperDelegate <NSObject>

// 获取商品信息
-(void)requestProduct:(IAPHelper*)sender start:(SKProductsRequest*)request;
-(void)requestProduct:(IAPHelper*)sender received:(SKProductsRequest*)request;

// 购买
-(void)paymentRequest:(IAPHelper*)sender start:(SKPayment*)payment;
-(void)paymentRequest:(IAPHelper*)sender purchased:(SKPaymentTransaction*)transaction;
-(void)paymentRequest:(IAPHelper*)sender restored:(SKPaymentTransaction*)transaction;
-(void)paymentRequest:(IAPHelper*)sender failed:(SKPaymentTransaction*)transaction;

// 恢复
-(void)restored:(IAPHelper*)sender withProductsIdArray:(NSArray*)productsIdArray;
-(void)restored:(IAPHelper*)sender failed:(NSError*)error; //李满

// 不支持内购
-(void)iapNotSupported:(IAPHelper*)sender;
@end

@interface IAPHelper : NSObject

+(IAPHelper*)sharedInstance;

@property(nonatomic,assign) id<IAPHelperDelegate> delegate;

-(void)setup;
-(void)destroy;
-(void)buyWithProductId:(NSString*)productId;

//发起恢复
-(void)restore;
@end
