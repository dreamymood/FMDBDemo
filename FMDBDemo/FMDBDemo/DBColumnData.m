//
//  DBColumnData.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DBColumnData.h"

@implementation DBColumnData

- (instancetype)initWithColumnName:(NSString *)name type:(NSString *)type autoIncrement:(BOOL)autoIncrement {
    if (self = [super init]) {
        self.name = name;
        self.type = type;
        self.autoIncrement =  autoIncrement;
    }
    return self;
}

@end
