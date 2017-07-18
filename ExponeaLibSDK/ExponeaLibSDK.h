//
//  ExponeaLibSDK.h
//  ExponeaLibSDK
//
//  Created by Jan Batora on 26/04/16.
//  Copyright © 2016 Exponea. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXPORT double ExponeaSDKVersionNumber;

//! Project version string for ExponeaSDK.
FOUNDATION_EXPORT const unsigned char ExponeaSDKVersionString[];

#import <StoreKit/StoreKit.h>

@interface ExponeaLibSDK : NSObject

@end

@interface ExponeaSegment : NSObject

- (instancetype)initWithName:(NSString *)name;
- (NSString *)getName;

@end

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
