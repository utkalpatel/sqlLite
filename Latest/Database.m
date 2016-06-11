//
//  Database.m
//  Autism Screen
//
//  Created by UTKAL on 11/30/15.
//  Copyright (c) 2015 UTKAL. All rights reserved.
//

#import "Database.h"
#import "define.h"
//#import "CommonMethod.h"



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


#pragma Database Storing Methods

+(NSString *) checkForNullVulueFor:(char *) coulumnValue {
    NSString * value = @"";
    
    if (coulumnValue != nil) {
        value = [NSString stringWithUTF8String:coulumnValue];
    }
    
    if ([value isEqualToString:@"NA"]) {
        value = @"";
    }
    
    if ([value isEqualToString:@"(null)"]) {
        value = @"";
    }
    return value;
}

/*!
 * @function isDatabaseExist
 * @Created 23-NOV UTKAL
 * @updated 23-NOV UTKAL
 * @discussion Check for database at specific directory if not then copy database.
 * @param N
 * @return Void
 * @since 1.0.0
 */

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
	if(success) return @"YES";
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	//NSString *databasePathFromApp = [FileSharingManager pathForResources:KHekxoRelayDatabase];
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
        NSLog(@"Database copy failuer");
    }
	// Copy the database from the package to the users filesystem
	
    
	
}

//================================================================================================================//

+(BOOL)recordExistOrNot:(NSString *)query{
    BOOL recordExist=NO;
    
   sqlite3 * Database;
    NSString *databasePath = [self pathForDatabase] ;
        if(sqlite3_open([databasePath UTF8String], &Database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(Database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
        {
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                recordExist=YES;
            }
            else
            {
                recordExist=NO;
                //////NSLog(@"%s,",sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement);
            sqlite3_close(Database);
        }
    }
    return recordExist;
}

//================================================================================================================//

#pragma mark Database Open Method

//================================================================================================================//

+(sqlite3 *) openDataBase {
    sqlite3 * edenAdultDatabase;
    NSString * databasePath = [Database pathForDatabase];
    
    if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK) {
        return edenAdultDatabase;
    }
    return edenAdultDatabase;
}

+(NSString *) pathForDatabase {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    
    return [documentsDir stringByAppendingPathComponent:@"studnets.sqlite"];
   
}
- (NSString *) getDBPath
{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    
    return [documentsDir stringByAppendingPathComponent:@"studnets.sqlite"];
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


#pragma mark - Update




#pragma mark - insert_dataInto DATABASE
+(id) insertData:(NSDictionary *) dictInfo tablename:(NSString*)tablename withCallBackHandler:(BOOL)handler
{
    
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    dictInfo = [Database checkForProperStringInDict:dictInfo];
    
    sqlite3_stmt *insertStmt = nil;
    
    sqlite3 * HexoDatabase;
    NSString * databasePath = [Database pathForDatabase];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
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
            
            
            
            if(sqlite3_prepare_v2(HexoDatabase, insert_stmt, -1, &insertStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(HexoDatabase));
            [arryResult addObject:[NSString stringWithFormat:@"Error"]];
            }
        }
        
        if(SQLITE_DONE != sqlite3_step(insertStmt)) {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(HexoDatabase));
           [arryResult addObject:[NSString stringWithFormat:@"Error"]];
        }
        else{
            NSLog(@"Inserted");
            }
    }
    
    sqlite3_reset(insertStmt);
    //sqlite3_finalize(insertStmt);
    sqlite3_close(HexoDatabase);
   
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

+(void)insertBulkDataToDatabase:(NSMutableArray *)array tablename:(NSString*)tablename columnDictionary:(NSArray*)arrColumnwithValue{
    
    
     NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    sqlite3 * database;
    
    const char *dbpath = [[Database pathForDatabase] UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        sqlite3_exec(database, "BEGIN TRANSACTION", 0, 0, 0);
        
        
        NSMutableString * insertSql=[[NSMutableString alloc]init];
        
        [insertSql appendString:[NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (",tablename]];
        
        
        for(int i=0;i<arrColumnwithValue.count;i++){
            [insertSql appendString:[NSString stringWithFormat:@"%@,",[[arrColumnwithValue objectAtIndex:i]valueForKey:kFields]]];
            
        }
        [insertSql deleteCharactersInRange:NSMakeRange([insertSql length]-1, 1)];
        [insertSql appendString:[NSString stringWithFormat:@")"]];
        
        [insertSql appendString:@" Values("];
        
        for(int i=0;i<arrColumnwithValue.count;i++){
            [insertSql appendString:@"?,"];
            
        }
        [insertSql deleteCharactersInRange:NSMakeRange([insertSql length]-1, 1)];
        [insertSql appendString:[NSString stringWithFormat:@")"]];
        
        const char *sqlStatement = [insertSql UTF8String];
        
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int hasError = 0;
            
            for (int i=0; i<[array count]; i++) {
                
                // sqlite3_bind_text(stmt, 2, [vrb UTF8String], -1, NULL);
                
                for(int  j=0;j<[arrColumnwithValue count];j++){
                    
                NSString *key=[[arrColumnwithValue objectAtIndex:j]valueForKey:Kvalues];
                NSString *value=[NSString stringWithFormat:@"%@",[[array objectAtIndex:i]valueForKey:key]];
                    
                sqlite3_bind_text(compiledStatement, j+1,[value UTF8String] , -1, SQLITE_TRANSIENT);
                    
                NSLog(@"%s",[[[arrColumnwithValue objectAtIndex:j]valueForKey:Kvalues] UTF8String]);
                    
               }
                
                if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                    hasError=1;
                    NSLog(@"Prepare-error %s", sqlite3_errmsg(database));
                 }
                
                sqlite3_reset(compiledStatement);
               
              }
            
            
            if( hasError == 0 ) {
                sqlite3_exec(database, "COMMIT", 0, 0, 0);
                NSLog(@"inserted successfully");
                [arryResult addObject:[NSString stringWithFormat:kSuccess]];
                
            }
            else {
                sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
                
                [arryResult addObject:[NSString stringWithFormat:kError]];
                 NSLog(@"can't insert:");
            }
            
            sqlite3_finalize(compiledStatement);
        }
        else{
            
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_close(database);
    }
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
}
+(void)UpdateBulkDataToDatabase:(NSMutableArray *)array tablename:(NSString*)tablename columnDictionary:(NSArray*)arrColumnwithValue conditionColumn:(NSArray*)ConditionWithDict{
    
    
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    sqlite3 * database;
    sqlite3_stmt *compiledStatement = NULL;
    int hasError = 0;
    
     const char *dbpath = [[Database pathForDatabase] UTF8String];
    
     NSMutableString * UpdateSql=[[NSMutableString alloc]init];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        sqlite3_exec(database, "BEGIN TRANSACTION", 0, 0, 0);
        
       for (int i=0; i<[array count]; i++) {
           
        [UpdateSql setString:@""];
        
        [UpdateSql appendString:[NSString stringWithFormat:@"UPDATE %@ SET ",tablename]];
        
        for(int j=0;j<arrColumnwithValue.count;j++){
            
            NSString *key=[[arrColumnwithValue objectAtIndex:j]valueForKey:Kvalues];
            NSString *value=[NSString stringWithFormat:@"%@",[[array objectAtIndex:i]valueForKey:key]];
            [UpdateSql appendString:[NSString stringWithFormat:@"%@='%@',",[[arrColumnwithValue objectAtIndex:j]valueForKey:kFields],value]];
        }
        [UpdateSql deleteCharactersInRange:NSMakeRange([UpdateSql length]-1, 1)];
        
        for(int k=0;k<ConditionWithDict.count;k++){
            
            if(k==0)
                [UpdateSql appendString:[NSString stringWithFormat:@" WHERE "]];
            
            NSDictionary *dict=[ConditionWithDict objectAtIndex:k];
            NSString *key=[dict valueForKey:kFields];
            
            [UpdateSql appendString:[NSString stringWithFormat:@"%@=%@ AND",
                                       key,[[array objectAtIndex:i] valueForKey:key]]];
            
            if(k==ConditionWithDict.count-1)
                [UpdateSql deleteCharactersInRange:NSMakeRange([UpdateSql length]-3, 3)];
            
        }
        
        const char *sqlStatement = [UpdateSql UTF8String];
           
           
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                    hasError=1;
                    NSLog(@"Prepare-error %s", sqlite3_errmsg(database));
                }
            
                    NSLog(@"sucess %d",i);
                sqlite3_reset(compiledStatement);
                
            }
       }
        
            if( hasError == 0 ) {
                sqlite3_exec(database, "COMMIT", 0, 0, 0);
                NSLog(@"Updated successfully");
                [arryResult addObject:[NSString stringWithFormat:kSuccess]];
                
                if(databaseSharedInstance.completionHandler){
                    databaseSharedInstance.completionHandler(arryResult);
                }
            }
            else {
                sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
                
                [arryResult addObject:[NSString stringWithFormat:kError]];
                
                if(databaseSharedInstance.completionHandler){
                    databaseSharedInstance.completionHandler(arryResult);
                }
                
                NSLog(@"can't insert:");
            }
            
          sqlite3_finalize(compiledStatement);
        
        
        sqlite3_close(database);
    }
    
}

+(void) getData:(NSDictionary *) dictInfo tablename:(NSString*)tablename
{
    sqlite3 *HexoDatabase;
    sqlite3_stmt *selectStatement=nil;
    
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        
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


+(void) getDataFromTable:(NSString*)SelectSql
{
    sqlite3 *HexoDatabase;
    sqlite3_stmt *selectStatement=nil;
    
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if(selectStatement == nil) {
            
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

+(void) getInnerJoinData:(NSString *)QueryString {
    sqlite3 *HexoDatabase;
    sqlite3_stmt *selectStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    const char *sql = [QueryString UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
    
        if(selectStatement == nil) {
            
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

        }
        
    }
    
    sqlite3_close(HexoDatabase);
    sqlite3_reset(selectStatement);
    selectStatement = nil;
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
}

+(void) importData:(NSString *)ImportSql{
    
    sqlite3 *HexoDatabase;
    sqlite3_stmt *importStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    const char *sql = [ImportSql UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if(importStatement == nil) {
            
           if(sqlite3_prepare_v2(HexoDatabase, sql, -1, &importStatement, NULL) == SQLITE_OK){
               
               
               if(SQLITE_DONE != sqlite3_step(importStatement))
                   NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(HexoDatabase));
               else
                   [arryResult addObject:[NSString stringWithFormat:kSuccess]];
               }
         }
    }
    
    sqlite3_close(HexoDatabase);
    sqlite3_reset(importStatement);
    importStatement = nil;
    
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
}

#pragma mark Delete Table Data

+(void)deleteFromTableName:(NSString *)TableName{
        
    sqlite3 *HexoDatabase;
    sqlite3_stmt *importStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *DeleteSql=[NSString stringWithFormat:@"DELETE FROM %@",TableName];
    
    const char *sql = [DeleteSql UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if(importStatement == nil) {
            
            if(sqlite3_prepare_v2(HexoDatabase, sql, -1, &importStatement, NULL) == SQLITE_OK){
                
                if(SQLITE_DONE != sqlite3_step(importStatement))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(HexoDatabase));
                else
                    [arryResult addObject:[NSString stringWithFormat:kSuccess]];
            }
        }
    }
    
    sqlite3_close(HexoDatabase);
    sqlite3_reset(importStatement);
    importStatement = nil;
    
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
}

#pragma mark Update TableData
#pragma mark Delete Table Data

+(void) UpdateTableData:(NSString *)updateSQL{
    
    sqlite3 *HexoDatabase;
    sqlite3_stmt *updateStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
  
    const char *sql = [updateSQL UTF8String];
    
    
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if(updateStatement == nil) {
            
            
            NSLog(@"%d",sqlite3_prepare_v2(HexoDatabase, sql, -1, &updateStatement, NULL));
            if(sqlite3_prepare_v2(HexoDatabase, sql, -1, &updateStatement, NULL) == SQLITE_OK){
                
                if(SQLITE_DONE != sqlite3_step(updateStatement))
                    NSAssert1(0, @"Error while Updating data. '%s'", sqlite3_errmsg(HexoDatabase));
                else
                    [arryResult addObject:[NSString stringWithFormat:kSuccess]];
            }
        }
    }
    
    sqlite3_reset(updateStatement);
   //sqlite3_finalize(updateStatement);
    sqlite3_close(HexoDatabase);
    updateStatement = nil;
    
    
     if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
      }
    

}
#pragma mark Insert and getLatestID

+(void)getMaxID:(NSString*)columnName tablename:(NSString*)tablename{
    
    sqlite3 *HexoDatabase;
    sqlite3_stmt *selectStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *sqlNsStr = [NSString stringWithFormat:@"SELECT MAX(%@) from %@",columnName,tablename];
    const char *sql = [sqlNsStr UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if (sqlite3_prepare_v2(HexoDatabase, sql, -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW) {
                
                NSMutableDictionary *dctRow = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                for (int i=0; i<sqlite3_column_count(selectStatement); i++)
                {
                    [dctRow setObject:[Database checkForNullValue:(char *)sqlite3_column_text(selectStatement,i)] forKey:@"MAX"];
                    [arryResult addObject:dctRow];
                }
            }
            sqlite3_reset(selectStatement);
        }
    }
    sqlite3_close(HexoDatabase);
    selectStatement = nil;
    
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
}
+(void) getIdforInsertedData:(NSDictionary *) dictInfo tablename:(NSString*)tablename requireColumnForID:(NSString*)columnName{
    
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    dictInfo = [Database checkForProperStringInDict:dictInfo];
    sqlite3_stmt *insertStmt = nil;
    
    sqlite3 * HexoDatabase;
    NSString * databasePath = [Database pathForDatabase];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
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
            
            
            
            if(sqlite3_prepare_v2(HexoDatabase, insert_stmt, -1, &insertStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(HexoDatabase));
                [arryResult addObject:@{Kresult:kError,KmaxID:@"0"}];
            }
        }
        
        if(SQLITE_DONE != sqlite3_step(insertStmt)) {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(HexoDatabase));
            [arryResult addObject:@{Kresult:kError,KmaxID:@"0"}];
        }
        else{
            NSLog(@"Inserted");
        }
    }
    
    sqlite3_close(HexoDatabase);
    sqlite3_reset(insertStmt);
    insertStmt = nil;    
    NSString *strID=[NSString stringWithFormat:@"%d",[self getMaxColumnIDWithoudCompletionHandler:tablename columnName:columnName]];
    [arryResult addObject:@{Kresult:kSuccess,KmaxID:strID}];
    //return @"success";
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
    
}

#pragma mark Without Handler

+(int)getMaxColumnIDWithoudCompletionHandler:(NSString*)tableName columnName:(NSString*)columnName{
    
    int columnID=0;
    sqlite3 *HexoDatabase;
    sqlite3_stmt *selectStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *sqlNsStr = [NSString stringWithFormat:@"SELECT MAX(%@) from %@",columnName,tableName];
    const char *sql = [sqlNsStr UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if (sqlite3_prepare_v2(HexoDatabase, sql, -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW) {
                
                NSMutableDictionary *dctRow = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                for (int i=0; i<sqlite3_column_count(selectStatement); i++)
                {
                    [dctRow setObject:[Database checkForNullValue:(char *)sqlite3_column_text(selectStatement,i)] forKey:@"MAX"];
                    [arryResult addObject:dctRow];
                }
            }
            sqlite3_reset(selectStatement);
        }
    }
    sqlite3_close(HexoDatabase);
    selectStatement = nil;
    
    columnID=[[[arryResult objectAtIndex:0]valueForKey:@"MAX"] integerValue];
    
    return columnID;
    
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

+(void) deleteDataWithID:(NSString*)strSql
{
    sqlite3 *HexoDatabase;
    sqlite3_stmt *importStatement=nil;
    NSString * databasePath = [Database pathForDatabase];
    NSMutableArray  *arryResult = [[NSMutableArray alloc] initWithCapacity:0];
   
    const char *sql = [strSql UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &HexoDatabase) == SQLITE_OK) {
        
        if(importStatement == nil) {
            
            if(sqlite3_prepare_v2(HexoDatabase, sql, -1, &importStatement, NULL) == SQLITE_OK){
                
                if(SQLITE_DONE != sqlite3_step(importStatement))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(HexoDatabase));
                else
                    [arryResult addObject:[NSString stringWithFormat:kSuccess]];
            }
        }
    }
    
    sqlite3_close(HexoDatabase);
    sqlite3_reset(importStatement);
    importStatement = nil;
        
    if(databaseSharedInstance.completionHandler){
        databaseSharedInstance.completionHandler(arryResult);
    }
}

@end


/*
 +(BOOL) updateNoteDetailsWithNoteID:(NSString *) noteID fieldName:(NSString *) filedName fieldValue:(NSString *) fieldValue
 {
 
 fieldValue = [Database changeAphostrophySForDataBaseInString:fieldValue];
 
 BOOL check = NO;
 
 sqlite3_stmt *updateStmt = nil;
 
 sqlite3 * edenAdultDatabase;
 NSString * databasePath = [Database pathForDatabase];
 
 if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK) {
 if(updateStmt == nil) {
 NSString * updateSql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where %@ = '%@'",kScreening_Notes, filedName, fieldValue,kScreening_Notes_NoteID, noteID];
 
 NSLog(@"updateSql:%@",updateSql);
 
 const char *update_stmt = [updateSql UTF8String];
 
 if(sqlite3_prepare_v2(edenAdultDatabase, update_stmt, -1, &updateStmt, NULL) != SQLITE_OK)
 NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(edenAdultDatabase));
 }
 
 if(SQLITE_DONE != sqlite3_step(updateStmt)) {
 NSAssert1(0, @"Error while updateing data. '%s'", sqlite3_errmsg(edenAdultDatabase));
 }
 else{
 check = YES;
 NSLog(@"Updated");
 }
 }
 
 sqlite3_reset(updateStmt);
 updateStmt = nil;
 
 return check;
 }


 
 +(BOOL) updateNoteMstWithNoteID:(NSString *) noteID fieldName:(NSString *) filedName fieldValue:(NSString *) fieldValue
 {
 
 fieldValue = [Database changeAphostrophySForDataBaseInString:fieldValue];
 
 BOOL check = NO;
 
 sqlite3_stmt *updateStmt = nil;
 
 sqlite3 * edenAdultDatabase;
 NSString * databasePath = [Database pathForDatabase];
 
 if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK) {
 if(updateStmt == nil) {
 NSString * updateSql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where %@ = '%@'",kScreening_Notes, filedName, fieldValue,kScreening_Notes_NoteID, noteID];
 
 NSLog(@"updateSql:%@",updateSql);
 
 const char *update_stmt = [updateSql UTF8String];
 
 if(sqlite3_prepare_v2(edenAdultDatabase, update_stmt, -1, &updateStmt, NULL) != SQLITE_OK)
 NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(edenAdultDatabase));
 }
 
 if(SQLITE_DONE != sqlite3_step(updateStmt)) {
 NSAssert1(0, @"Error while updateing data. '%s'", sqlite3_errmsg(edenAdultDatabase));
 }
 else{
 check = YES;
 NSLog(@"Updated");
 }
 }
 
 sqlite3_reset(updateStmt);
 updateStmt = nil;
 
 return check;
 }
 
  / *
 +(NSArray*) selectFromNoteMstForNoteID:(NSString *) NoteID
 {
 NSMutableArray* dataArray = [[NSMutableArray alloc]init];
 
 sqlite3_stmt * selectStmt = nil;
 
 NSString * databasePath = [Database pathForDatabase];
 sqlite3 * edenAdultDatabase;
 if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK)
 {
 
 if(selectStmt == nil)
 {
 NSString * selecteSql = [NSString stringWithFormat:@"select * from %@ where %@ = %@",kScreening_Notes, kScreening_Notes_NoteID, NoteID];
 
 const char *select_stmt = [selecteSql UTF8String];
 
 sqlite3_stmt *sqlStmt;
 if(sqlite3_prepare_v2(database, [createSQL UTF8String], -1, &sqlStmt, nil)!=SQLITE_OK){
 NSLog(@"Problem with prepare statement"); //this is where the code gets stuck and I don't know why
 }else{
 
 while(sqlite3_step(sqlStmt)==SQLITE_ROW){
 NSInteger number = sqlite3_column_int(sqlStmt, 0);
 NSString *title = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStmt, 1)];
 [myarray addObject:title];
 }
 sqlite3_finalize(sqlStmt);
 }
 sqlite3_close(database);
 
 }
 
 #pragma mark Database Path Methods
 
 //================================================================================================================//
 
 +(NSString *) pathForDatabase {
 
 NSString *databasePath = [FileSharingManager pathForDatabaseLibraryFolder] ;
 
 return databasePath;
 }
 
 +(BOOL) deleteFromNoteMstForNoteID:(NSString *) NoteID
 {
 BOOL isDeleted = NO;
 
 sqlite3_stmt * deleteStmt = nil;
 
 sqlite3 * edenAdultDatabase;
 NSString * databasePath = [Database pathForDatabase];
 
 if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK)
 {
 if(deleteStmt == nil)
 {
 NSString * deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = %@",kScreening_Notes, kScreening_Notes_NoteID, NoteID];
 
 NSLog(@"deleteSql:%@",deleteSql);
 
 const char *delete_stmt = [deleteSql UTF8String];
 
 if(sqlite3_prepare_v2(edenAdultDatabase, delete_stmt, -1, &deleteStmt, NULL) != SQLITE_OK)
 NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(edenAdultDatabase));
 }
 
 if(SQLITE_DONE != sqlite3_step(deleteStmt)) {
 NSAssert1(0, @"Error while deleteing data. '%s'", sqlite3_errmsg(edenAdultDatabase));
 }
 else{
 isDeleted = YES;
 NSLog(@"deleted");
 }
 }
 
 sqlite3_reset(deleteStmt);
 deleteStmt = nil;
 
 return isDeleted;
 
 }
 
 + (NSString *) getLastAddedRecordInScreeningNotes {
 sqlite3 * edenAdultDatabase = [Database openDataBase];
 
 NSString * noteID = @"";
 
 NSString * selectQuery = [NSString stringWithFormat:@"select max(%@) from %@",kScreening_Notes_NoteID,kScreening_Notes];
 const char *sqlStatement = [selectQuery UTF8String];
 
 sqlite3_stmt *compiledStatement;
 
 if(sqlite3_prepare_v2(edenAdultDatabase, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
 // Loop through the results and add them to the feeds array
 while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
 // Read the data from the result row
 noteID = [Database checkForNullVulueFor:(char *)sqlite3_column_text(compiledStatement, 0)];
 }
 }
 
 NSLog(@"%@",noteID);
 
 // Release the compiled statement from memory
 sqlite3_finalize(compiledStatement);
	sqlite3_close(edenAdultDatabase);
	
 return noteID;
 }
 *
 +(NSArray*) selectFromNoteMstForNoteID:(NSDictionary *) dictInfo tablename:(NSString*)tablename
 {
 NSMutableArray* dataArray = [[NSMutableArray alloc]init];
 
 sqlite3_stmt * selectStmt = nil;
 
 NSString * databasePath = [Database pathForDatabase];
 sqlite3 * edenAdultDatabase;
 if(sqlite3_open([databasePath UTF8String], &edenAdultDatabase) == SQLITE_OK)
 {
 
 if(selectStmt == nil)
 {
 
 NSString * selecteSql = [NSString stringWithFormat:@"select *  from %@  where ",tablename];
 
 NSArray * arrFields = [dictInfo allKeys];
 NSArray * arrValues = [dictInfo allValues];
 
 for (int i =0 ; i<[arrFields count] ; i++) {
 if (i == 0) {
 selecteSql = [selecteSql stringByAppendingString:[NSString stringWithFormat:@"%@='%@'",[arrFields objectAtIndex:i],[arrValues objectAtIndex:i]]];
 }
 else {
 selecteSql = [selecteSql stringByAppendingString:[NSString stringWithFormat:@"and %@='%@'",[arrFields objectAtIndex:i],[arrValues objectAtIndex:i]]];
 }
 }
 
 
 const char *select_stmt = [selecteSql UTF8String];
 
 sqlite3_stmt *sqlStmt;
 if(sqlite3_prepare_v2(edenAdultDatabase, [createSQL UTF8String], -1, &sqlStmt, nil)!=SQLITE_OK){
 NSLog(@"Problem with prepare statement");
 }else{
 
 while(sqlite3_step(sqlStmt)==SQLITE_ROW){
 NSInteger number = sqlite3_column_int(sqlStmt, 0);
 NSString *title = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStmt, 1)];
 [myarray addObject:title];
 }
 sqlite3_finalize(sqlStmt);
 }
 sqlite3_close(database);
 
 }
 
 }
 }*/




