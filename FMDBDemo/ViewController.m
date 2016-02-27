//
//  ViewController.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "DBModel.h"
#import "DBTable.h"
#import "DBColumnData.h"
#import "DBModelExample.h"

NSString *FMXLowerCamelCaseFromSnakeCase(NSString *input)
{
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if (c == '_') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

@interface ViewController ()

@property (nonatomic, strong) NSString *addTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    id value = [self valueForKey:column.propertyName] ?: NSNull.null;
    
    
    [[DBManager sharedInstance]registerDatabaseWithName:@"Photo" path:@"Photo.sqlite"];
    
//    DBModel *model = [[DBModel alloc]init];
//    [model addColumnWithName:@"id" type:@"INTEGER" autoIncrement:YES withPrimaryKey:YES];
//    [model addColumnWithName:@"name" type:@"text"];
    DBModelExample *model = [[DBModelExample alloc] init];
    DBTable *table = [[DBTable alloc] initWithTableName:@"info" model:model configuration:[[DBManager sharedInstance] configuration:@"Photo"]];
    model.addTime = @"sss";
    
    [table saveTableWithModel:model];
    
    DBModelExample *model1 = [table modelByPrimaryKey:@(1)];
    NSLog(@"%@", model1.id);
    
//    DBTableData *tableData = [[DBTableData alloc]init];
//    [tableData addColumnWithName:@"id" type:@"INTEGER" autoIncrement:YES withPrimaryKey:YES];
//    [tableData addColumnWithName:@"name" type:@"text" autoIncrement:NO withPrimaryKey:NO];
//    DBModel *model = [[DBModel alloc]initWithTableName:@"info" tableData:tableData configuration:[[DBManager sharedInstance]configuration:@"Photo"]];
//    
//    DBColumnData *columnData = [[DBColumnData alloc]initWithColumnName:@"hehe" type:@"text" autoIncrement:NO];
//    DBColumnData *column2 = [[DBColumnData alloc]initWithColumnName:@"xx" type:@"text" autoIncrement:NO];
//    [model addColumnData:columnData];
//    [model addColumnData:column2];
//    
//    [model saveTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
