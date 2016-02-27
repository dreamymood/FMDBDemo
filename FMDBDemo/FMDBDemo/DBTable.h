//
//  DBTable.h
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBConfiguration;
@class FMDatabase;
@class DBModel;
@class DBColumnData;

@interface DBTable : NSObject

@property (nonatomic, strong) DBConfiguration *configuration;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) DBModel *model;

- (instancetype)initWithTableName:(NSString *)tableName model:(DBModel *)model configuration:(DBConfiguration *)configuration;

//- (void)addColumnData:(DBColumnData *)columnData;
//- (void)addColumns:(NSArray *)columns;

- (BOOL)saveTableWithModel:(id)model;

- (DBModel *)modelByPrimaryKey:(id)primaryKeyValue;

@end
