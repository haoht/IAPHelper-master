//
//  IAPHelper.m
//  In-App-Purchase demo
//
//  Created by liman on 15-2-26.
//
//

#import "IAPHelper.h"
@interface IAPHelper()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property(nonatomic,weak) SKPaymentQueue *paymentQueue;

@end

@implementation IAPHelper

#pragma mark - tool method
-(BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

-(void)requestProduct:(NSString*)productId
{
    NSArray *product = [[NSArray alloc] initWithObjects:productId,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    
    if ([self.delegate respondsToSelector:@selector(requestProduct:start:)]) {
        [self.delegate requestProduct:self start:request];
    }
}


#pragma mark - public method
+(IAPHelper*)sharedInstance
{
    static IAPHelper *__singletion = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __singletion = [[self alloc] init];
        
    });
    
    return __singletion;
}

-(void)setup
{
    _paymentQueue = [SKPaymentQueue defaultQueue];
    //监听SKPayment过程
    [_paymentQueue addTransactionObserver:self];
    NSLog(@"IAPHelper 开启交易监听");
}

-(void)destroy
{
    //解除监听
    [_paymentQueue removeTransactionObserver:self];
    _paymentQueue = nil;
    NSLog(@"IAPHelper 注销交易监听");
    
}

-(void)buyWithProductId:(NSString*)productId
{
    if([self canMakePayments])
    {
       [self requestProduct:productId];
    }
    else
    {
        // 不支持内购
        if ([self.delegate respondsToSelector:@selector(iapNotSupported:)]) {
            [self.delegate iapNotSupported:self];
        }
    }
}

//发起恢复
-(void)restore
{
    [_paymentQueue restoreCompletedTransactions];
}


#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(requestProduct:received:)]) {
        [self.delegate requestProduct:self received:request];
    }
    
    NSLog(@"didReceiveResponse called:");
    NSLog(@"prodocuId:%@",response.products);
    NSLog(@"=======================================================");
    
    NSArray *productArray = response.products;
    if(productArray != nil && productArray.count>0)
    {
        SKProduct *product = [productArray objectAtIndex:0];
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        SKPayment* payment = [SKPayment paymentWithProduct:product];
        [_paymentQueue addPayment:payment];
        
        if ([self.delegate respondsToSelector:@selector(paymentRequest:start:)]) {
            [self.delegate paymentRequest:self start:payment];
        }
    }
}


#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"updatedTransactions called:");
    NSMutableArray* restoreArray = [[NSMutableArray alloc]init];
    for(SKPaymentTransaction* transaction in transactions)
    {
        NSLog(@"%@",transaction.payment.productIdentifier);
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                if ([self.delegate respondsToSelector:@selector(paymentRequest:purchased:)]) {
                    [self.delegate paymentRequest:self purchased:transaction];
                }
                [_paymentQueue finishTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateRestored:
                [restoreArray addObject:transaction.payment.productIdentifier];
                if ([self.delegate respondsToSelector:@selector(paymentRequest:restored:)]) {
                    [self.delegate paymentRequest:self restored:transaction];
                }
                [_paymentQueue finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                if ([self.delegate respondsToSelector:@selector(paymentRequest:failed:)]) {
                    [self.delegate paymentRequest:self failed:transaction];
                }
                [_paymentQueue finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
    if(restoreArray.count > 0)
    {
        if ([self.delegate respondsToSelector:@selector(restored:withProductsIdArray:)]) {
            [self.delegate restored:self withProductsIdArray:restoreArray];
        }
    }
    NSLog(@"=======================================================");
}

//交易完成之后，调用； 据我理解应该是[_paymentQueue finishTransaction:transaction]; 调用成功之后的回掉
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"removedTransactions called:");
    NSLog(@"=======================================================");
}

//恢复失败
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restoreCompletedTransactionsFailedWithError called:");
    NSLog(@"error:%@",error);
    NSLog(@"=======================================================");
    
    if ([self.delegate respondsToSelector:@selector(restored:failed:)]) {
        [self.delegate restored:self failed:error]; //李满
    }
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished called:");
    NSLog(@"SKPaymentQueue:%@",queue);
    NSLog(@"=======================================================");
}
// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    NSLog(@"updatedDownloads called:");
    NSLog(@"=======================================================");
}

@end
