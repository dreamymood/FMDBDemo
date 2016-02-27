//
//  DBModelExample.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DBModelExample.h"

@implementation DBModelExample

- (instancetype)init {
    if (self = [super init]) {
        [self addColumnWithName:@"id" type:@"INTEGER" autoIncrement:YES withPrimaryKey:YES];
        [self addColumnWithName:@"add_time" type:@"text"];
    }
    return self;
}

@end
