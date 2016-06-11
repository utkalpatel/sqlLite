//
//  Database.h
//  Autism Screen
//
//  Created by UTKAL on 11/30/15.
//  Copyright (c) 2015 UTKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import "FileSharingManager.h"


@interface Database : NSObject
{
}

@property (nonatomic, copy) void (^completionHandler)(NSMutableArray*);


+(Database *) databaseSharedInstance;
+(NSString *) checkForNullVulueFor:(char *) coulumnValue;
+(NSString*) isDatabaseExist;
+(NSString *) pathForDatabase;
+(sqlite3 *) openDataBase;

//Notes

+(BOOL)recordExistOrNot:(NSString *)query;

+(BOOL) updateNoteDetailsWithNoteID:(NSString *) noteID fieldName:(NSString *) filedName fieldValue:(NSString *) fieldValue;
+(BOOL) updateUserServerIDInDB:(NSString *)UserServerId where:(NSString *)emailId;
+(NSDictionary *) checkForProperStringInDict:(NSDictionary *) dictInfo;
+(NSString *) changeAphostrophySForDataBaseInString:(NSString *) string;
//+ (NSString *) getLastAddedRecordInScreeningNotes;

//+(BOOL) updateNoteMstWithNoteID:(NSString *) noteID fieldName:(NSString *) filedName fieldValue:(NSString *) fieldValue;

+(void) deleteFromTableName:(NSString *)TableName;
+(void) deleteDataWithID:(NSString*)deleteSql;
+(void) getDataFromTable:(NSString*)SelectSql;
+(id) insertData:(NSDictionary *) dictInfo tablename:(NSString*)tablename withCallBackHandler:(BOOL)handler;
+(void) getData:(NSDictionary *) dictInfo tablename:(NSString*)tablename;
+(void) getInnerJoinData:(NSString *)QueryString;
+(void) UpdateTableData:(NSString *)updateSQL;
+(void) importData:(NSString *)ImportSql;
+(void) getMaxID:(NSString*)columnName tablename:(NSString*)tablename;
+(void) getIdforInsertedData:(NSDictionary *) dictInfo tablename:(NSString*)tablename requireColumnForID:(NSString*)columnName;

//--------Bulk insert_update---------------------
+(void)insertBulkDataToDatabase:(NSMutableArray *)array tablename:(NSString*)tablename columnDictionary:(NSArray*)arrColumnwithValue;
+(void)UpdateBulkDataToDatabase:(NSMutableArray *)array tablename:(NSString*)tablename columnDictionary:(NSArray*)arrColumnwithValue conditionColumn:(NSArray*)ConditionWithDict;
@end
