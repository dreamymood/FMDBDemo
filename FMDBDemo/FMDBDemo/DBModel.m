//
//  DBModel.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DBModel.h"
#import "DBColumnData.h"

@implementation DBModel

- (instancetype)init {
    if (self = [super init]) {
        self.columns = [[NSMutableArray alloc] init];
        self.isNew = YES;
    }
    return self;
}

- (void)addColumnWithName:(NSString *)columnName type:(NSString *)type {
    [self addColumnWithName:columnName type:type autoIncrement:NO withPrimaryKey:NO];
}

- (void)addColumnWithName:(NSString *)columnName type:(NSString *)type autoIncrement:(BOOL)autoIncrement {
    [self addColumnWithName:columnName type:type autoIncrement:autoIncrement withPrimaryKey:NO];
}

- (void)addColumnWithName:(NSString *)columnName type:(NSString *)type autoIncrement:(BOOL)autoIncrement withPrimaryKey:(BOOL)key {
    DBColumnData *column = [[DBColumnData alloc]initWithColumnName:columnName type:type autoIncrement:autoIncrement];
    [self.columns addObject:column];
    if (key) {
        self.primaryKeyName = columnName;
    }
}

- (void)addColumns:(NSArray *)columns primaryKey:(NSString *)primaryKeyName {
    [self.columns addObjectsFromArray:columns];
    self.primaryKeyName = primaryKeyName;
}

- (void)addColumns:(NSArray *)columns {
    [self.columns addObjectsFromArray:columns];
}

- (void)addColumnData:(DBColumnData *)columnData primaryKey:(NSString *)primaryKeyName {
    [self.columns addObject:columnData];
    self.primaryKeyName = primaryKeyName;
}

- (void)addColumnData:(DBColumnData *)columnData {
    [self.columns addObject:columnData];
}

@end
