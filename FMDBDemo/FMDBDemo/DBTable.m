//
//  DBTable.m
//  FMDBDemo
//
//  Created by Daniel on 16/1/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DBTable.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DBConfiguration.h"
#import "DBModel.h"
#import "DBColumnData.h"
#import "DBManager.h"

NSString *UpperCamelCaseFromSnakeCase(NSString *input)
{
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if (idx == 0) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
        } else if (c == '_') {
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

NSString *LowerCamelCaseFromSnakeCase(NSString *input)
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

SEL SetterSelectorFromColumnName(NSString *input)
{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", UpperCamelCaseFromSnakeCase(input)]);
}

@interface DBTable ()

@property (nonatomic, strong) NSMutableDictionary *sqls;

@end

@implementation DBTable

- (instancetype)init {
    if (self = [super init]) {
        self.configuration = nil;
        self.tableName = nil;
    }
    return self;
}

- (instancetype)initWithTableName:(NSString *)tableName model:(DBModel *)model configuration:(DBConfiguration *)configuration {
    if (self = [super init]) {
        self.configuration = configuration;
        self.tableName = tableName;
        self.model = model;
        self.sqls = [[NSMutableDictionary alloc] init];
        [self.sqls setObject:[self sqlWithCreateTable] forKey:@"Create"];
        
//        [self createTableWithConfiguration:configuration];
        [self saveTable];
    }
    return self;
}

- (NSString *)sqlWithCreateTable {
    if (!self.configuration || !self.tableName || !self.model) {
        return nil;
    }
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",self.tableName];
    for (DBColumnData *column in self.model.columns) {
        [sql appendFormat:@" %@ %@ ",column.name,column.type];
        if (column.name == self.model.primaryKeyName) {
            [sql appendFormat:@" primary key "];
        }
        if (column.autoIncrement && [column.type.uppercaseString isEqualToString:@"INTEGER"]) {
            [sql appendFormat:@" AUTOINCREMENT "];
        }
        [sql appendFormat:@" ,"];
    }
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendFormat:@")"];
    return [NSString stringWithString:sql];
}

- (BOOL)saveTable {
    FMDatabase *db = [self.configuration database];
    if (![db open]) {
        NSLog(@"Could not open database: %@",db.lastErrorMessage);
        return NO;
    }
    [db beginTransaction];
    BOOL success = YES;
    if ([self.sqls.allKeys containsObject:@"Create"]) {
        NSString *createSQL = [self.sqls objectForKey:@"Create"];
        if(![db executeUpdate:createSQL]) {
            NSLog(@"Could not create table '%@': %@",self.tableName,db.lastErrorMessage);
            success = NO;
        }
    }
    if ([self.sqls.allKeys containsObject:@"AddColumns"]) {
        NSArray *addColumnSqls = [self.sqls objectForKey:@"AddColumns"];
        for (NSString *addColumnSql in addColumnSqls) {
            if (![db executeUpdate:addColumnSql]) {
                NSLog(@"Could not add column with error:%@",db.lastErrorMessage);
                success = NO;
            }
        }
    }
    
    if (![db commit]) {
        [db rollback];
        NSLog(@"commit sql error:%@",db.lastErrorMessage);
        success = NO;
    }
    [db close];
    return success;
}

- (void)addColumnData:(DBColumnData *)columnData {
    NSMutableArray *columns;
    if ([self.sqls.allKeys containsObject:@"AddColumns"]) {
        columns = [self.sqls objectForKey:@"AddColumns"];
    }else {
        columns = [[NSMutableArray alloc]init];
    }
    [columns addObject:[self sqlWithAddColumnData:columnData]];
    [self.sqls setObject:columns forKey:@"AddColumns"];
    [self.model addColumnData:columnData];
}

- (NSString *)sqlWithAddColumnData:(DBColumnData *)columnData {
    if (!self.configuration || !self.tableName || !self.model) {
        return nil;
    }
    NSMutableString *sql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@",self.tableName,[NSString stringWithFormat:@"%@ %@",columnData.name,columnData.type]];
    return sql;
}

- (void)addColumns:(NSArray *)columns {
    for (DBColumnData *columnData in columns) {
        [self addColumnData:columnData];
    }
}

- (BOOL)createTableWithConfiguration:(DBConfiguration *)configuration {
    self.configuration = configuration;
    FMDatabase *db = [self.configuration database];
    if (![db open]) {
        NSLog(@"Could not open database: %@",db.lastErrorMessage);
        return NO;
    }
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name = '%@' ",self.tableName]];
    if (![rs next]) {
        [db beginTransaction];
        NSString *createTableSQL = [NSString stringWithFormat:@"create table %@ (version INTGER PRIMARY KEY NOT NULL)",self.tableName];
        if (![db executeUpdate:createTableSQL]) {
            NSLog(@"Could not create table '%@': %@",self.tableName,db.lastErrorMessage);
            return NO;
        }else{
            NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (version) values (0)",self.tableName];
            if (![db executeUpdate:insertSQL]) {
                NSLog(@"Could not insert first record for table '%@': %@",self.tableName,db.lastErrorMessage);
            }
        }
        if (![db commit]) {
            [db rollback];
            return NO;
        }
        NSLog(@"Create version table:%@",self.tableName);
    }
    [db close];
    return YES;
}

- (BOOL)saveTableWithModel:(id)model {
    if (![model isKindOfClass:[DBModel class]]) {
        return NO;
    }
    self.model = model;
    if (self.model.isNew) {
        return [self insertDatabase];
    } else {
        return [self updateDatabase];
    }
}

- (BOOL)insertDatabase {
    FMDatabase *db = self.configuration.database;
    if (![db open]) {
        NSLog(@"Could not open database: %@",db.lastErrorMessage);
        return NO;
    }
    [db beginTransaction];
    
    NSArray *columns = self.model.columns;
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (DBColumnData *column in columns) {
        NSString *columnName = column.name;
        id value = [self.model valueForKey:LowerCamelCaseFromSnakeCase(columnName)] ?: NSNull.null;
        if ([columnName isEqualToString:self.model.primaryKeyName] || value == NSNull.null) {
            continue;
        }
        [fields addObject:columnName];
        [values addObject:value];
    }
    
    NSMutableString *query = [[NSMutableString alloc] init];
    [query appendFormat:@"insert into `%@` ", self.tableName];
    [query appendFormat:@"(`%@`) values (%@?)", [fields componentsJoinedByString:@","],
     [@"" stringByPaddingToLength:((fields.count - 1) * 2) withString:@"?," startingAtIndex:0]];
    
    
    BOOL success = YES;
    success = [db executeUpdate:query withArgumentsInArray:values];
    
    SEL selector = SetterSelectorFromColumnName(self.model.primaryKeyName);
    if ([self respondsToSelector:@selector(selector)]) {
        [self performSelector:selector withObject:@([db lastInsertRowId])];
    }
    
    self.model.isNew = NO;
    
    if (![db commit]) {
        [db rollback];
        NSLog(@"commit sql error:%@",db.lastErrorMessage);
        success = NO;
    }
    [db close];
    
    return success;
}

- (BOOL)updateDatabase {
    if (![self valueForKey:LowerCamelCaseFromSnakeCase(self.model.primaryKeyName)]) {
        return NO;
    }
    
    FMDatabase *db = self.configuration.database;
    if (![db open]) {
        NSLog(@"Could not open database: %@",db.lastErrorMessage);
        return NO;
    }
    [db beginTransaction];
    
    NSArray *columns = self.model.columns;
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (DBColumnData *column in columns) {
        NSString *columnName = column.name;
        id value = [self.model valueForKey:LowerCamelCaseFromSnakeCase(columnName)] ?: NSNull.null;
        if ([columnName isEqualToString:self.model.primaryKeyName] || value == NSNull.null) {
            continue;
        }
        [fields addObject:columnName];
        [values addObject:value];
    }
    
    [values addObject:[self valueForKey:LowerCamelCaseFromSnakeCase(self.model.primaryKeyName)] ?: NSNull.null];
    
    NSMutableString *query = [[NSMutableString alloc] init];
    [query appendFormat:@"update `%@` set ", self.tableName];
    [query appendFormat:@"`%@` = ? ", [fields componentsJoinedByString:@"`=?,`"]];
    [query appendFormat:@"where `%@` = ?", self.model.primaryKeyName];
    
    BOOL success = YES;
    success = [db executeUpdate:query withArgumentsInArray:values];
    
    SEL selector = SetterSelectorFromColumnName(self.model.primaryKeyName);
    if ([self respondsToSelector:@selector(selector)]) {
        [self performSelector:selector withObject:@([db lastInsertRowId])];
    }
    
    self.model.isNew = NO;
    
    if (![db commit]) {
        [db rollback];
        NSLog(@"commit sql error:%@",db.lastErrorMessage);
        success = NO;
    }
    [db close];
    
    return success;
}

//查询
- (DBModel *)modelByPrimaryKey:(id)primaryKeyValue {
    DBModel *model = nil;
    FMDatabase *db = self.configuration.database;
    if (![db open]) {
        NSLog(@"Could not open database: %@",db.lastErrorMessage);
        return nil;
    }
    [db beginTransaction];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from `%@` where `%@` = ?",
                                        self.tableName,
                                        self.model.primaryKeyName], primaryKeyValue];
    if ([rs next]) {
        model = [self modelWithResultSet:rs];
    }
    
    if (![db commit]) {
        [db rollback];
        NSLog(@"commit sql error:%@",db.lastErrorMessage);
        return nil;
    }
    [db close];
    
    return model;
}

- (DBModel *)modelWithResultSet:(FMResultSet *)rs {
    NSArray *columns = self.model.columns;
    
    DBModel *model = [[DBModel alloc] init];
    model.isNew = NO;
    
    for (DBColumnData *column in columns) {
        id value = nil;
        id object = [rs objectForColumnName:column.name];
        if ([object isEqual:[NSNull null]]) {
            value = nil;
        } else if ([[column.name lowercaseString] isEqualToString:@"integer"]) {
            value = [NSNumber numberWithInt:[rs intForColumn:column.name]];
        } else if ([[column.name lowercaseString] isEqualToString:@"real"]) {
            value = [NSNumber numberWithFloat:[rs doubleForColumn:column.name]];
        } else if ([[column.name lowercaseString] isEqualToString:@"text"]) {
            value = [rs stringForColumn:column.name];
        }
        if (value) {
            NSString *propertyName = LowerCamelCaseFromSnakeCase(column.name);
            [model setValue:value forKey:propertyName];
        }
    }
    return model;
}


@end
