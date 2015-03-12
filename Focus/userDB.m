//
//  userDB.m
//  HppleDemo
//
//  Created by  吕欣韵 on 2015-01-18.
//
//

#import "userDB.h"

@implementation userDB

- (void)creatDataBase{
    sqlite3 *sqlite = nil;
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/data.sqlite"];
    
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    
    if (result != SQLITE_OK) {
        NSLog(@"Fail to init db");
        return;
    }
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS garden (p_id INT AUTO_INCREMENT primary key, p_date DATE, p_type TEXT)";
    
    char *error;
    
    result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &error);
    
    if (result != SQLITE_OK) {
        NSLog(@"FAIL TO INIT");
        return;
    }
    
    sqlite3_close(sqlite);
}

- (void)inserToDataBaseWithType: (NSString *)type{
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/data.sqlite"];
    
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    
    if (result != SQLITE_OK) {
        NSLog(@"Fail to init db");
        return;
    }
    
    NSString *sql = @"INSERT INTO garden (p_date, p_type) VALUES (date(\"now\"), ?)";
    
    sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL);
//
    sqlite3_bind_text(stmt, 1, [type UTF8String], -1, NULL);
    

    
    result = sqlite3_step(stmt);
    if (result == SQLITE_ERROR || result == SQLITE_MISUSE) {
        NSLog(@"FAIL TO INSERT");
    }
    
}

- (NSMutableArray *)loadTypeFromDataBaseWithOffset: (int)offset {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/data.sqlite"];
    
    int result = sqlite3_open([filePath UTF8String], &sqlite);
    
    if (result != SQLITE_OK) {
        NSLog(@"Fail to init db");
        return nil;
    }
    NSString *sql1 = @"SELECT p_type from garden where p_date = date(\"now\")";
    NSString *sql2 = [NSString stringWithFormat:@"SELECT p_type from garden where p_date = date(\"now\") - %d", offset];
    if (offset == 0) {
        sqlite3_prepare_v2(sqlite, [sql1 UTF8String], -1, &stmt, NULL);
    } else {
        sqlite3_prepare_v2(sqlite, [sql2 UTF8String], -1, &stmt, NULL);
    }
    
        
    result = sqlite3_step(stmt);
    while (result == SQLITE_ROW) {
        char *username = (char *)sqlite3_column_text(stmt, 0);
        NSString *userNameStr = [NSString stringWithCString:username encoding:NSUTF8StringEncoding];
        [array addObject:userNameStr];
        result = sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    
    return array;
}



@end
