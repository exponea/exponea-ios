//
//  Device.h
//  ExponeaSDK
//
//  Created by Igi on 3/12/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Device : NSObject

extern NSString * const SDK;
extern NSString * const SDK_VERSION;
extern NSString * const OS;

+ (NSMutableDictionary *)deviceProperties;

@end
