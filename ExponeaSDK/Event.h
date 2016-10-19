//
//  Event.h
//  ExponeaSDK
//
//  Created by Igi on 2/5/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//

#import "Command.h"

@interface Event : Command

- (instancetype)initWithIds:(NSDictionary *)ids andProjectId:(NSString *)projectId andWithType:(NSString *)type
          andWithProperties:(NSDictionary *)properties andWithTimestamp:(NSNumber *)timestamp;

@end
