//
//  db.m
//  databaseProject
//
//  Created by developer on 6/11/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import "Database.h"
#import "define.h"

@implementation Database


static Database * databaseSharedInstance = nil;

+ (Database *) databaseSharedInstance {
    @synchronized(self) {
        if (databaseSharedInstance == nil) {
            databaseSharedInstance = [[Database alloc] init];
        }
    }
    return databaseSharedInstance;
}

+(NSString*) isDatabaseExist {
    // Check if the SQL database has already been saved to the users phone, if not then copy it over
    BOOL success;
    NSError *error;
    
    // Create a FileManager object, we will use this to check the status
    // of the database and to copy it over if required
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databasePath =[self pathForDatabase];
    
    // Check if the database has already been created in the users filesystem
    success = [fileManager fileExistsAtPath:databasePath];
    
    // If the database already exists then return without doing anything
    if(success)
        return @"YES";
    
    
    NSString *databasePathFromApp  = [self pathForDatabase];
    success = [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    
    if (success == YES)
    {
        NSLog(@"Databse Successfully Copied");
        return @"Copied";
    }
    else
    {
        if (error)
        {
            NSLog(@"Database Copy error :  %@",error);
        }
        return @"Error";
    }
    
}

#pragma mark DatabasePath
+(NSString *) pathForDatabase {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    
    return [documentsDir stringByAppendingPathComponent:@"studnets.sqlite"];
    
}

#pragma mark Database Open Method
+(sqlite3 *) openDataBase {
    sqlite3 * edenAdultDatabase;
    NSString * databasePath = [Database pathForDatabase];
    
    if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK) {
        return edenAdultDatabase;
    }
    return edenAdultDatabase;
}

#pragma mark - insert_dataInto DATABASE
+(id) insertData:(NSDictionary *) dictInfo tablename:(NSString*)tablename withCallBackHandler:(BOOL)handler
{
    
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    dictInfo = [Database checkForProperStringInDict:dictInfo];
    
    sqlite3_stmt *insertStmt = nil;
    
    sqlite3 * Database_;
    NSString * databasePath = [Database pathForDatabase];
    
    if(sqlite3_open([databasePath UTF8String], &Database_) == SQLITE_OK) {
        if(insertStmt == nil) {
            
            NSString * insertSql = [NSString stringWithFormat:@"insert into %@ (",tablename];
            
            NSArray * arrFields = [dictInfo allKeys];
            NSArray * arrValues = [dictInfo allValues];
            
            for (int i =0 ; i<[arrFields count] ; i++) {
                if (i != [arrFields count] - 1) {
                    insertSql = [insertSql stringByAppendingString:[NSString stringWithFormat:@"%@,",[arrFields objectAtIndex:i]]];
                }
                else {
                    insertSql = [insertSql stringByAppendingString:[NSString stringWithFormat:@"%@) values(",[arrFields objectAtIndex:i]]];
                }
            }
            
            for (int i =0 ; i<[arrValues count] ; i++) {
                if (i != [arrValues count] - 1) {
                    insertSql = [insertSql stringByAppendingString:[NSString stringWithFormat:@"'%@',",[arrValues objectAtIndex:i]]];
                }
                else {
                    insertSql = [insertSql stringByAppendingString:[NSString stringWithFormat:@"'%@')",[arrValues objectAtIndex:i]]];
                }
            }
            
            NSLog(@"insertSql:%@",insertSql);
            
            const char *insert_stmt = [insertSql UTF8String];
            
            
            
            if(sqlite3_prepare_v2(Database_, insert_stmt, -1, &insertStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(Database_));
                [arryResult addObject:[NSString stringWithFormat:@"Error"]];
            }
        }
        
        if(SQLITE_DONE != sqlite3_step(insertStmt)) {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(Database_));
            [arryResult addObject:[NSString stringWithFormat:@"Error"]];
        }
        else{
            NSLog(@"Inserted");
        }
    }
    
    sqlite3_reset(insertStmt);
    //sqlite3_finalize(insertStmt);
    sqlite3_close(Database_);
    
    insertStmt = nil;
    
    //return @"success";
    [arryResult addObject:[NSString stringWithFormat:kSuccess]];
    
    
    if(handler==YES){
        if(databaseSharedInstance.completionHandler){
            databaseSharedInstance.completionHandler(arryResult);
        }
    }
    
    return arryResult;
    
}

#pragma mark Update TableData
#pragma mark Delete Table Data

+(void) UpdateTableData:(NSString *)updateSQL{
    
    sqlite3 *Database_;
    sqlite3_stmt *updateStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    const char *sql = [updateSQL UTF8String];
    
    
    
    if(sqlite3_open([databasePath UTF8String], &Database_) == SQLITE_OK) {
        
        if(updateStatement == nil) {
            
            
            NSLog(@"%d",sqlite3_prepare_v2(Database_, sql, -1, &updateStatement, NULL));
            if(sqlite3_prepare_v2(Database_, sql, -1, &updateStatement, NULL) == SQLITE_OK){
                
                if(SQLITE_DONE != sqlite3_step(updateStatement))
                    NSAssert1(0, @"Error while Updating data. '%s'", sqlite3_errmsg(Database_));
                else
                    [arryResult addObject:[NSString stringWithFormat:kSuccess]];
            }
        }
    }
    
    sqlite3_reset(updateStatement);
    //sqlite3_finalize(updateStatement);
    sqlite3_close(Database_);
    updateStatement = nil;
    
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
    
}

#pragma mark DeleteTableData
+(void) deleteDataWithID:(NSString*)strSql
{
    sqlite3 *Database_;
    sqlite3_stmt *importStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    const char *sql = [strSql UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &Database_) == SQLITE_OK) {
        
        if(importStatement == nil) {
            
            if(sqlite3_prepare_v2(Database_, sql, -1, &importStatement, NULL) == SQLITE_OK){
                
                if(SQLITE_DONE != sqlite3_step(importStatement))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(Database_));
                else
                    [arryResult addObject:[NSString stringWithFormat:kSuccess]];
            }
        }
    }
    
    sqlite3_close(Database_);
    sqlite3_reset(importStatement);
    importStatement = nil;
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
}

#pragma mark GetDataFromTable
+(void) getDataFromTable:(NSString*)tableName
{
    sqlite3 *HexoDatabase;
    sqlite3_stmt *selectStatement=nil;
    
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if(selectStatement == nil) {
                        
            NSString * SelectSql = [NSString stringWithFormat:@"select *  from %@",tableName];
            const char *sql = [SelectSql UTF8String];
            
            NSLog(@"SelectSql:%@",SelectSql);
            
            int returnValue = sqlite3_prepare_v2(HexoDatabase, sql, -1, &selectStatement, NULL);
            
            if(returnValue == SQLITE_OK){
                
                sqlite3_bind_text(selectStatement, 1, sql, -1, SQLITE_TRANSIENT);
                NSMutableArray *arrColumns = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (int i=0; i<sqlite3_column_count(selectStatement); i++)
                {
                    const char *st = sqlite3_column_name(selectStatement, i);
                    [arrColumns addObject:[NSString stringWithCString:st encoding:NSUTF8StringEncoding]];
                    
                }
                int intRow =1;
                
                while(sqlite3_step(selectStatement) == SQLITE_ROW)
                {
                    NSMutableDictionary *dctRow = [[NSMutableDictionary alloc] initWithCapacity:0];
                    for (int i=0; i<sqlite3_column_count(selectStatement); i++)
                    {
                        [dctRow setObject:[Database checkForNullValue:(char *)sqlite3_column_text(selectStatement,i)] forKey:
                         [arrColumns objectAtIndex:i]];
                    }
                    [arryResult addObject:dctRow];
                    intRow ++;
                }
                
            }
            else{
                NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(HexoDatabase));
                NSMutableDictionary *dctRow = [[NSMutableDictionary alloc] initWithCapacity:0];
                [dctRow setObject:@"StatmentError" forKey:@"error"];
                [arryResult addObject:dctRow];
                if(databaseSharedInstance.completionHandler){
                    databaseSharedInstance.completionHandler(arryResult);
                }//error = StatmentError;
                
            }
            
        }
        else{
            NSAssert1(0, @"Error while Database open '%s'", sqlite3_errmsg(HexoDatabase));
            NSLog(@"Database locked");
        }
        
        sqlite3_finalize(selectStatement);
        
    }
    
    sqlite3_close(HexoDatabase);
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
}
+(void) getData:(NSDictionary *) dictInfo tablename:(NSString*)tablename
{
    sqlite3 *database_;
    sqlite3_stmt *selectStatement=nil;
    
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(sqlite3_open([databasePath UTF8String], &database_) == SQLITE_OK) {
        
        
        if(selectStatement == nil) {
            
            
            NSString * SelectSql = [NSString stringWithFormat:@"select *  from %@  where ",tablename];
            
            NSArray * arrFields = [dictInfo allKeys];
            NSArray * arrValues = [dictInfo allValues];
            
            for (int i =0 ; i<[arrFields count] ; i++) {
                if (i == 0) {
                    SelectSql = [SelectSql stringByAppendingString:[NSString stringWithFormat:@"%@='%@'",[arrFields objectAtIndex:i],[arrValues objectAtIndex:i]]];
                }
                else {
                    SelectSql = [SelectSql stringByAppendingString:[NSString stringWithFormat:@"and %@='%@'",[arrFields objectAtIndex:i],[arrValues objectAtIndex:i]]];
                }
            }
            
            const char *sql = [SelectSql UTF8String];
            
            NSLog(@"SelectSql:%@",SelectSql);
            
            int returnValue = sqlite3_prepare_v2(database_, sql, -1, &selectStatement, NULL);
            
            if(returnValue == SQLITE_OK){
                
                sqlite3_bind_text(selectStatement, 1, sql, -1, SQLITE_TRANSIENT);
                NSMutableArray *arrColumns = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (int i=0; i<sqlite3_column_count(selectStatement); i++)
                {
                    const char *st = sqlite3_column_name(selectStatement, i);
                    [arrColumns addObject:[NSString stringWithCString:st encoding:NSUTF8StringEncoding]];
                    
                }
                int intRow =1;
                
                while(sqlite3_step(selectStatement) == SQLITE_ROW)
                {
                    NSMutableDictionary *dctRow = [[NSMutableDictionary alloc] initWithCapacity:0];
                    for (int i=0; i<sqlite3_column_count(selectStatement); i++)
                    {
                        [dctRow setObject:[Database checkForNullValue:(char *)sqlite3_column_text(selectStatement,i)] forKey:
                         [arrColumns objectAtIndex:i]];
                    }
                    [arryResult addObject:dctRow];
                    intRow ++;
                }
                
            }
            else{
                NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database_));
                NSMutableDictionary *dctRow = [[NSMutableDictionary alloc] initWithCapacity:0];
                [dctRow setObject:@"StatmentError" forKey:@"error"];
                [arryResult addObject:dctRow];
                if(databaseSharedInstance.completionHandler){
                    databaseSharedInstance.completionHandler(arryResult);
                }//error = StatmentError;
                
            }
            
        }
        else{
            NSAssert1(0, @"Error while Database open '%s'", sqlite3_errmsg(database_));
            NSLog(@"Database locked");
        }
        
        sqlite3_finalize(selectStatement);
        
    }
    
    sqlite3_close(database_);
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
}


+(NSString *) checkForNullValue:(char *) coulumnValue {
    NSString * value = @"";
    
    if (coulumnValue != nil) {
        value = [NSString stringWithUTF8String:coulumnValue];
    }
    
    if ([value isEqualToString:@"NA"]) {
        value = @"";
    }
    
    if ([value isEqualToString:@"(null)"] || [value isEqualToString:@"<null>"]) {
        value = @"";
    }
    return value;
}

+(NSDictionary *) checkForProperStringInDict:(NSDictionary *) dictInfo
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:dictInfo];
    
    NSMutableArray * arrValues = [NSMutableArray array];
    NSMutableArray * arrKeys = [NSMutableArray array];
    
    [arrKeys addObjectsFromArray:[dict allKeys]];
    [arrValues addObjectsFromArray:[dict allValues]];
    
    NSLog(@"%@",[arrValues description]);
    NSLog(@"%@",[arrKeys description]);
    
    for (int i = 0; i<[arrValues count]; i++) {
        
        id obj = [arrValues objectAtIndex:i];
        NSString * class = [[obj class] description];
        
        if ([class rangeOfString:@"string" options:1].location != NSNotFound) {
            NSString * str = [Database changeAphostrophySForDataBaseInString:[arrValues objectAtIndex:i]];
            [dict setObject:str forKey:[arrKeys objectAtIndex:i]];
        }
    }
    
    return (NSDictionary *) dict;
}

+(NSString *) changeAphostrophySForDataBaseInString:(NSString *) string
{
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return string;
}
@end
