//
//  DBConfiguration.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DBConfiguration.h"

@implementation DBConfiguration

- (instancetype)initWithDatabasePath:(NSString *)databasePath {
    if (self = [super init]) {
        self.databasePath = databasePath;
        NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.databasePathInDocuments = [dir stringByAppendingPathComponent:databasePath];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.databasePathInDocuments]) {
            [fm createFileAtPath:self.databasePathInDocuments contents:nil attributes:nil];
            NSLog(@"Create initial database file: %@",self.databasePathInDocuments);
        }
    }
    return self;
}

- (FMDatabase *)database {
    return [FMDatabase databaseWithPath:self.databasePathInDocuments];
}

@end
