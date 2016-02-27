//
//  DBConfiguration.h
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBConfiguration : NSObject

@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) NSString *databasePathInDocuments;

- (instancetype)initWithDatabasePath:(NSString *)databasePath;

- (FMDatabase *)database;

@end
