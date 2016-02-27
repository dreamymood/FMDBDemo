//
//  DBManager.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DBManager.h"
#import "DBConfiguration.h"

@interface DBManager ()

@property (nonatomic, strong) NSMutableDictionary *configurations;
@property (nonatomic, strong) NSMutableDictionary *tables;

@end

@implementation DBManager

+ (DBManager *)sharedInstance {
    static DBManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[DBManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.configurations = [[NSMutableDictionary alloc] init];
        self.tables = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerDatabaseWithName:(NSString *)database path:(NSString *)databasePath {
    DBConfiguration *configuration = [[DBConfiguration alloc] initWithDatabasePath:databasePath];
    [self.configurations setObject:configuration forKey:database];
    NSLog(@"Registered database [%@]: %@",database,configuration.databasePathInDocuments);
}

- (void)registerDefaultDatabseWithPath:(NSString *)databasePath {
    [self registerDatabaseWithName:@"Default" path:databasePath];
}

- (void)destoryDatabase:(NSString *)database {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [[self.configurations objectForKey:database] databasePathInDocuments];
    if (path && [fm fileExistsAtPath:path]) {
        [fm removeItemAtPath:path error:nil];
    }
}

- (void)destoryDefaultDatabase {
    [self destoryDatabase:@"Default"];
}

- (DBConfiguration *)configuration:(NSString *)database {
    return [self.configurations objectForKey:database];
}

- (DBConfiguration *)defaultConfiguration {
    return [self configuration:@"Default"];
}

- (FMDatabase *)database:(NSString *)database {
    DBConfiguration *configuration = [self.configurations objectForKey:database];
    if (!configuration) {
        return nil;
    }
    return [configuration database];
}

- (FMDatabase *)defaultDatabase {
    return [self database:@"Default"];
}






@end
