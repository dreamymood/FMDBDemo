//
//  DBModel.h
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBColumnData.h"

@interface DBModel : NSObject

@property (nonatomic, strong) NSMutableArray *columns;
@property (nonatomic, strong) NSString *primaryKeyName;

- (void)addColumnWithName:(NSString *)columnName type:(NSString *)type ;
- (void)addColumnWithName:(NSString *)columnName type:(NSString *)type autoIncrement:(BOOL)autoIncrement;
- (void)addColumnWithName:(NSString *)columnName type:(NSString *)type autoIncrement:(BOOL)autoIncrement withPrimaryKey:(BOOL)key;


- (void)addColumnData:(DBColumnData *)columnData primaryKey:(NSString *)primaryKeyName;
- (void)addColumnData:(DBColumnData *)columnData;
- (void)addColumns:(NSArray *)columns primaryKey:(NSString *)primaryKeyName;
- (void)addColumns:(NSArray *)columns;

@property (assign, nonatomic) BOOL isNew;

@end
