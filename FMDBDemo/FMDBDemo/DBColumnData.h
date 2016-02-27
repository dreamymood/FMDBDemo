//
//  DBColumnData.h
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBColumnData : NSObject

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,assign)BOOL autoIncrement;

- (instancetype)initWithColumnName:(NSString *)name type:(NSString *)type autoIncrement:(BOOL)autoIncrement;


@end
