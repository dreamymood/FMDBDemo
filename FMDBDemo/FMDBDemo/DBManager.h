//
//  DBManager.h
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConfiguration.h"

@interface DBManager : NSObject

+ (DBManager *)sharedInstance;

- (void)registerDatabaseWithName:(NSString *)database path:(NSString *)databasePath;
- (void)registerDefaultDatabseWithPath:(NSString *)databasePath;

- (void)destoryDatabase:(NSString *)database;
- (void)destoryDefaultDatabase;

- (DBConfiguration *)configuration:(NSString *)database;
- (DBConfiguration *)defaultConfiguration;

- (FMDatabase *)database:(NSString *)database;
- (FMDatabase *)defaultDatabase;

@end
