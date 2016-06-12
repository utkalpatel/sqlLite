//
//  db.h
//  databaseProject
//
//  Created by developer on 6/11/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject
@property (nonatomic, copy) void (^completionHandler)(NSMutableArray*);

+(Database *) databaseSharedInstance;
+(NSString*) isDatabaseExist;
+(NSString *) pathForDatabase;
+(sqlite3 *) openDataBase;

//Get Data from Database
+(void) getData:(NSDictionary *) dictInfo tablename:(NSString*)tablename;
//GetData from table
+(void) getDataFromTable:(NSString*)SelectSql;
//Insert Database
+(id) insertData:(NSDictionary *) dictInfo tablename:(NSString*)tablename withCallBackHandler:(BOOL)handler;

//Update Database
+(BOOL) updateNoteDetailsWithNoteID:(NSString *) noteID fieldName:(NSString *) filedName fieldValue:(NSString *) fieldValue;
+(void) UpdateTableData:(NSString *)updateSQL;

//Delete database record
+(void) deleteDataWithID:(NSString*)deleteSql;
@end
