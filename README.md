应用内购买IAP的封装 (In-App Purchase (IAP) wrapper)
======

	[[IAPHelper sharedInstance] setup];
	[[IAPHelper sharedInstance] buyWithProductId:@"product_id"];
	
	[[IAPHelper sharedInstance] restore];
	
	// 代理回调:
	
	// 购买
	-(void)paymentRequest:(IAPHelper*)sender start:(SKPayment*)payment;
	-(void)paymentRequest:(IAPHelper*)sender purchased:(SKPaymentTransaction*)transaction;
	-(void)paymentRequest:(IAPHelper*)sender restored:(SKPaymentTransaction*)transaction;
	-(void)paymentRequest:(IAPHelper*)sender failed:(SKPaymentTransaction*)transaction;
	
	// 恢复
	-(void)restored:(IAPHelper*)sender withProductsIdArray:(NSArray*)productsIdArray;
	-(void)restored:(IAPHelper*)sender failed:(NSError*)error; 