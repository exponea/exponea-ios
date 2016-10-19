//
//  Session.h
//  ExponeaSDK
//
//  Created by Igi on 3/12/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preferences.h"

@interface Session : NSObject

- (instancetype)initWithPreferences:(Preferences *)preferences;
- (void)restart:(NSMutableDictionary *)customer;
- (void)run;

@end
