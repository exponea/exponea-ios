//
//  Exponea.h
//  ExponeaSDK
//
//  Created by Igi on 2/4/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//
#define DEPRECATED_ATTRIBUTE __attribute__((deprecated))

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ExponeaSegment.h"

typedef void (^onSegmentReceive) (BOOL wasSuccessful, ExponeaSegment *segment, NSString *error);

@interface Exponea : NSObject
<SKPaymentTransactionObserver, SKProductsRequestDelegate>

+ (id)sharedInstanceWithToken:(NSString *)token andWithTarget:(NSString *)target andWithCustomerDict:(NSMutableDictionary *)customer DEPRECATED_ATTRIBUTE;
+ (id)sharedInstanceWithToken:(NSString *)token andWithTarget:(NSString *)target andWithCustomer:(NSString *)customer DEPRECATED_ATTRIBUTE;
+ (id)sharedInstanceWithToken:(NSString *)token andWithTarget:(NSString *)target DEPRECATED_ATTRIBUTE;
+ (id)sharedInstanceWithToken:(NSString *)token andWithCustomerDict:(NSMutableDictionary *)customer DEPRECATED_ATTRIBUTE;
+ (id)sharedInstanceWithToken:(NSString *)token andWithCustomer:(NSString *)customer DEPRECATED_ATTRIBUTE;
+ (id)sharedInstanceWithToken:(NSString *)token DEPRECATED_ATTRIBUTE;

+ (id)getInstance:(NSString *)token andWithTarget:(NSString *)target andWithCustomerDict:(NSMutableDictionary *)customer;
+ (id)getInstance:(NSString *)token andWithTarget:(NSString *)target andWithCustomer:(NSString *)customer;
+ (id)getInstance:(NSString *)token andWithTarget:(NSString *)target;
+ (id)getInstance:(NSString *)token andWithCustomerDict:(NSMutableDictionary *)customer;
+ (id)getInstance:(NSString *)token andWithCustomer:(NSString *)customer;
+ (id)getInstance:(NSString *)token;

+ (void)identifyWithCustomerDict:(NSMutableDictionary *)customer andUpdate:(NSDictionary *)properties;
+ (void)identifyWithCustomer:(NSString *)customer andUpdate:(NSDictionary *)properties DEPRECATED_ATTRIBUTE;
+ (void)identifyWithCustomerDict:(NSMutableDictionary *)customer;
+ (void)identifyWithCustomer:(NSString *)customer DEPRECATED_ATTRIBUTE;
+ (void)identify:(NSString *)customer andUpdate:(NSDictionary *)properties;
+ (void)identify:(NSString *)customer;

+ (void)update:(NSDictionary *)properties;

+ (void)track:(NSString *)type withProperties:(NSDictionary *)properties withTimestamp:(NSNumber *)timestamp;
+ (void)track:(NSString *)type withProperties:(NSDictionary *)properties;
+ (void)track:(NSString *)type withTimestamp:(NSNumber *)timestamp;
+ (void)track:(NSString *)type;
+ (void)trackVirtualPayment:(NSString *)currency withAmount:(NSNumber *)amount withItemName:(NSString *)itemName withItemType:(NSString *)itemType;
+ (void)trackSessionStart;
+ (void)trackSessionEnd;

+ (void)setSessionProperties:(NSDictionary *)properties;
+ (void)setSessionTimeOut:(double)value;

+ (void)enableAutomaticFlushing;
+ (void)disableAutomaticFlushing;
+ (void)flush;

+ (void)registerPushNotifications;
+ (void)addPushNotificationsToken:(NSData *)token;

+ (void)getCurrentSegment:(NSString *)segmentationId withProjectSecret:(NSString *)projectSecretToken withCallBack:(onSegmentReceive)callback;

@end
