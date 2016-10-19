//
//  CommandManager.m
//  ExponeaSDK
//
//  Created by Igi on 2/5/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//

#import "CommandManager.h"
#import "DbQueue.h"
#import "Http.h"
#import "Preferences.h"
#import "Device.h"


int const MAX_RETRIES = 5;
int const RETRY_DELAY = 5;

@interface CommandManager ()

@property DbQueue *dbQueue;
@property Http *http;
@property NSString *token;
@property Preferences *preferences;
@property int lastRetryDelay;
@property NSTimer *retryTimer;
@property int retriesLeft;
@property UIBackgroundTaskIdentifier task;

@end

@implementation CommandManager

- (instancetype)initWithTarget:(NSString *)target andWithToken:(NSString *)token {
    self = [super init];
    
    self.dbQueue = [[DbQueue alloc] init];
    self.http = [[Http alloc] initWithTarget: target];
    self.token = token;
    self.preferences = [Preferences sharedInstance];
    
    return self;
}

- (void)schedule:(Command *)command {
    [self.dbQueue schedule:[command getPayload]];
}

- (void)flush {
    self.retriesLeft = MAX_RETRIES;
    self.lastRetryDelay = 1;

    [self ensureBackgroundTask];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self) {
            [self executeFlush:nil];
        }
    });

}
- (void)executeFlush:(NSTimer *)timer {
    if (timer != nil) {
        [timer invalidate];
    } else {
        [self.retryTimer invalidate];
    }
    self.retryTimer = nil;
    long succ = 1;
    while ((succ = [self executeBatch]) > 0) {
    }
    if ([self.dbQueue isEmpty]) {
        [self ensureBackgroundTaskFinished];
        return;
    }
    if (succ == 0 || self.retriesLeft == 0) {
        [self ensureBackgroundTaskFinished];
    }
    else {
        self.retriesLeft--;
        self.lastRetryDelay *= RETRY_DELAY;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, MIN(self.lastRetryDelay, pow(RETRY_DELAY, 5)) * NSEC_PER_SEC),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^(void){
            [self executeFlush:nil];
        });

    }
}

- (void)ensureBackgroundTask {
    UIApplication *app = [UIApplication sharedApplication];
    
    if (self.task == UIBackgroundTaskInvalid) {
        self.task = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:self.task];
            self.task = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)ensureBackgroundTaskFinished {
    if (self.task != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.task];
        self.task = UIBackgroundTaskInvalid;
    }
}

- (NSNumber *)nowInSeconds {
    return [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
}

- (void)setAge:(NSMutableDictionary *)command {
    if (command[@"data"] && command[@"data"][@"age"]) {
        command[@"data"][@"age"] = [NSNumber numberWithLong:[[self nowInSeconds] longValue] - [command[@"data"][@"age"] longValue]];
    }
}

- (void)setCookieId:(NSMutableDictionary *)command {
    if (command[@"data"] && command[@"data"][@"ids"] && ![command[@"data"][@"ids"][@"cookie"] length]) {
        command[@"data"][@"ids"][@"cookie"] = [self.preferences objectForKey:@"campaignCookie"];
    }
    
    if (command[@"data"] && command[@"data"][@"customer_ids"] && ![command[@"data"][@"customer_ids"][@"cookie"] length]) {
        command[@"data"][@"customer_ids"][@"cookie"] = [self.preferences objectForKey:@"campaignCookie"];
    }
}

- (BOOL)ensureCookieId {
    NSString *campaignCookie = [self.preferences objectForKey:@"campaignCookie" withDefault:@""];
    
    if ([campaignCookie isEqualToString:@""]) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        campaignCookie = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        
        NSDictionary *response = [self.http post:@"crm/customers/track" withPayload:@{
            @"ids": @{@"cookie": campaignCookie},
            @"project_id": self.token,
            @"device": [Device deviceProperties]
        }];
        
        if (response) {
            NSNumber *success = response[@"success"];
            if (!success.boolValue) {
                NSLog(@"<EXPONEA> Error negotiating cookie id: %@", response[@"errors"]);
                return NO;
            }
            campaignCookie = response[@"data"][@"ids"][@"cookie"];
            NSLog(@"<EXPONEA> Negotiated cookie id");
            [self.preferences setObject:campaignCookie forKey:@"campaignCookie"];
            
            NSString *cookie = [self.preferences objectForKey:@"cookie" withDefault:@""];
            
            if ([cookie isEqualToString:@""]) {
                [self.preferences setObject:campaignCookie forKey:@"cookie"];
            }
            
            return YES;
        }
        
        return NO;
    }
    
    NSString *cookie = [self.preferences objectForKey:@"cookie" withDefault:@""];
    
    if ([cookie isEqualToString:@""]) {
        [self.preferences setObject:campaignCookie forKey:@"cookie"];
    }
    
    return YES;
}

- (long)executeBatch {
    if (![self ensureCookieId]) {
        NSLog(@"<EXPONEA> Failed to negotiate cookie id.");
        return NO;
    }
    
    NSMutableSet *successful = [[NSMutableSet alloc] init];
    NSMutableSet *failed = [[NSMutableSet alloc] init];
    NSArray *requests = [self.dbQueue pop];
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    NSMutableDictionary *request;
    NSDictionary *result;
    NSString *status;
    
    if (![requests count]) return NO;
    
    for (NSDictionary *req in requests) {
        [self setAge:req[@"command"]];
        [self setCookieId:req[@"command"]];
        [commands addObject:req[@"command"]];
        [failed addObject:req[@"id"]];
    }
    
    NSDictionary *response = [self.http post:@"bulk" withPayload:@{@"commands": commands}];
    
    if (response && response[@"results"]) {
        for (int i = 0; i < [response[@"results"] count] && i < [requests count]; ++i) {
            request = requests[i];
            result = response[@"results"][i];
            status = [result[@"status"] lowercaseString];
            
            if ([status isEqualToString:@"ok"]) {
                [failed removeObject:request[@"id"]];
                [successful addObject:request[@"id"]];
            }
            else if ([status isEqualToString:@"retry"]) {
                [failed removeObject:request[@"id"]];
            }
        }
    }
    
    [self.dbQueue clear:[successful allObjects] andFailed:[failed allObjects]];
    
    NSLog(@"<EXPONEA> Sent commands: %d successful, %d failed out of %d", (int) [successful count], (int) [failed count], (int) [requests count]);
    
    return [failed count] > 0 ? (-1 * [failed count]) : [successful count];
}

@end
