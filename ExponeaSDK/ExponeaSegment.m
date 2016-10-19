//
//  ExponeaSegment.m
//  ExponeaSDK
//
//  Created by Roland Rogansky on 07/09/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//

#import "ExponeaSegment.h"

@interface ExponeaSegment ()

@property NSString *name;

@end

@implementation ExponeaSegment

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    self.name = name;
    
    return self;
}

- (NSString *)getName {
    return self.name;
}

@end
