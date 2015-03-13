//
//  userDB.h
//  HppleDemo
//
//  Created by  吕欣韵 on 2015-01-18.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface userDB : NSObject

- (void)creatDataBase;
- (void)inserToDataBaseWithType: (NSString *)type;
- (NSMutableArray *)loadTypeFromDataBaseWithOffset: (int)offset;
- (NSMutableArray *)loadDateFromDataBase;

@end
