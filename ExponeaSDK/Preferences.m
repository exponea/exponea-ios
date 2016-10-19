//
//  Preferences.m
//  ExponeaSDK
//
//  Created by Igi on 2/4/15.
//  Copyright (c) 2016 Exponea. All rights reserved.
//

#import "Preferences.h"

@interface Preferences ()

@property DbManager *dbManager;
@property NSMutableDictionary *prefs;
@property NSObject *lockAccess;

@end

@implementation Preferences

- (instancetype)init {
    self = [super init];
    
    self.lockAccess = [[NSObject alloc] init];
    self.dbManager = [[DbManager alloc] initWithDatabaseFilename: DB_FILE];
    [self createDbIfNecessary];
    
    self.prefs = [self load];
    
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)objectForKey:(NSString *)key {
    @synchronized(self.lockAccess){
        return self.prefs[key];
    }
}

- (id)objectForKey:(NSString *)key withDefault:(id)defaultValue {
    @synchronized(self.lockAccess){
        id value = [self objectForKey:key];
    
        if (!value) {
            return defaultValue;
        }
    
        return value;
    }
}

- (void)setObject:(id)value forKey:(NSString *)key {
    if (value && key) {
        @synchronized(self.lockAccess) {
            [self.prefs setValue:value forKey:key];
            [self save:self.prefs];
        }
    }
}

- (void)removeObjectForKey:(NSString *)key {
    @synchronized(self.lockAccess){
        if (key) {
            [self.prefs removeObjectForKey:key];
            [self save:self.prefs];
        }
    }
}

- (NSMutableDictionary *)load {
    @synchronized(self.lockAccess){
        NSArray *prefsArray = [self.dbManager loadDataFromDb:@"SELECT * FROM preferences;"];
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
    
        for (NSArray *option in prefsArray) {
            prefs[option[0]] = option[1];
        }
    
        return prefs;
    }
}

- (void)save:(NSDictionary *)preferences {
    @synchronized(self.lockAccess){
        [self.dbManager executeQuery:@"DELETE FROM preferences;"];
    
        for (NSString *key in preferences) {
            [self.dbManager executeQuery:[NSString stringWithFormat:@"INSERT INTO preferences (key, value) VALUES ('%@', '%@')", key, preferences[key]]];
        }
    }
}

- (void)createDbIfNecessary {
    @synchronized(self.lockAccess){
        [self.dbManager executeQuery:@"CREATE TABLE IF NOT EXISTS preferences ("
                                 " key TEXT PRIMARY KEY NOT NULL,"
                                 " value TEXT NOT NULL);"];
    }
}

@end
