//
//  QueryBuilder.m
//  HEKXO Relay
//
//  Created by Utkal Patel on 12/3/15.
//  Copyright © 2015 Utkal Patel. All rights reserved.
//

#import "QueryBuilder.h"
//#import "DefineHeader.h"
#import "define.h"

@implementation QueryBuilder
@synthesize FirstTableFields,SecondTableFields,ThirdTableFields,UnionFields,ConditonalFieldsWithInnerQuery,AliasFields,ConditonalFieldsWithDict,UpdateFieldsWithDict;


-(id) init {
    self = [super init];
    if (self){
        FirstTableFields=[[NSMutableArray alloc]init];
        SecondTableFields=[[NSMutableArray alloc]init];
        ThirdTableFields=[[NSMutableArray alloc]init];
        UnionFields=[[NSMutableArray alloc]init];
        ConditonalFieldsWithInnerQuery=[[NSMutableArray alloc]init];
        ConditonalFieldsWithDict=[[NSMutableArray alloc]init];
        AliasFields=[[NSDictionary alloc]init];
        UpdateFieldsWithDict=[[NSMutableArray alloc]init];
        
    }
    return self;
}



/*!
 * @function -(NSMutableString*)getQueryfor:(NSString*)firstTable  secondtable:(NSString*)secondtable
 * @Created 1-DEC-15 UTKAL
 * @updated 1-DEC-15 UTKAL
 * @discussion This method will  make  inner join query as per given table name and filed array.
 * @param (NSString*)firstTable  secondtable:(NSString*)secondtable
 * @return NSMutableString - inner join query
 * @since V1.0.0
 */


-(NSMutableString*)getJoinQueryfor:(NSString*)firstTable  secondtable:(NSString*)secondtable{
        
        NSMutableString *JoinQuery=[[NSMutableString alloc]init];
        [JoinQuery appendString:@"select "];
        
        
        //--------Form query with first table fields
        for(int i=0;i<FirstTableFields.count;i++){
            
            
            NSArray * keys = [[FirstTableFields objectAtIndex:i] allKeys];
            
            if(keys.count>0){
                for (NSString *keyobj in keys)
                {
                  [JoinQuery appendString:[NSString stringWithFormat:@"%@.%@ AS %@,",firstTable,[FirstTableFields objectAtIndex:i],keyobj]];
                }
            
            }else{
            
                    [JoinQuery appendString:[NSString stringWithFormat:@"%@.%@,",firstTable,[FirstTableFields objectAtIndex:i]]];
            }
            
            
        }
        //--------Append query with Second table fields
        for(int j=0;j<SecondTableFields.count;j++){
            
            NSArray * keys = [[SecondTableFields objectAtIndex:j] allKeys];
            
            if(keys.count>0){
                for (NSString *keyobj in keys)
                {
                    [JoinQuery appendString:[NSString stringWithFormat:@"%@.%@ AS %@,",firstTable,[SecondTableFields objectAtIndex:j],keyobj]];
                }
            }
            else{
                [JoinQuery appendString:[NSString stringWithFormat:@"%@.%@,",secondtable,[SecondTableFields objectAtIndex:j]]];
            }
            
            if(j==SecondTableFields.count-1)
                [JoinQuery deleteCharactersInRange:NSMakeRange([JoinQuery length]-1, 1)];
            
        }
    
        
        [JoinQuery appendString:[NSString stringWithFormat:@" FROM %@ INNER JOIN  %@ ON ",firstTable,secondtable]];
        
        
        //--------Append query with join fields
        for(int j=0;j<UnionFields.count;j++){
            
            [JoinQuery appendString:[NSString stringWithFormat:@"%@.%@ = %@.%@ AND",firstTable,[UnionFields objectAtIndex:j],secondtable,[UnionFields objectAtIndex:j]]];
            
            if(j==UnionFields.count-1)
                [JoinQuery deleteCharactersInRange:NSMakeRange([JoinQuery length]-3, 3)];
        }
    
        
        //--------Append query with where cond
        for(int i=0;i<ConditonalFieldsWithDict.count;i++){
            
            if(i==0)
              [JoinQuery appendString:[NSString stringWithFormat:@" WHERE "]];
            
            
            NSDictionary *dict=[ConditonalFieldsWithDict objectAtIndex:i];
            
            [JoinQuery appendString:[NSString stringWithFormat:@" %@.%@=%@ AND",
                                     [dict valueForKey:kTable],
                                     [dict valueForKey:kFields],
                                     [dict valueForKey:Kvalues]]];
            
            if(i==ConditonalFieldsWithDict.count-1)
               [JoinQuery deleteCharactersInRange:NSMakeRange([JoinQuery length]-3, 3)];
            
        }
    
        [self ReleaseObjectsMemoryContent];
        return JoinQuery;
        
    }

-(NSString*)importdataFrom:(NSString*)firstTableName ToanotherTable:(NSString*)anotherTableName{
    
    
    /*INSERT INTO RelayUserImageMaster (ImageId
                                      , ImageName
                                      , ImageBytes
                                      , CreatedDate
                                      ,ModifiedDate
                                      ,ImageType
                                      ,ImageIndex
                                      ,IsSync
                                      
                                      )
    SELECT ImageId
    , ImageName
    , ImageBytes
    , CreatedDate
    ,ModifiedDate
    ,'C' as  ImageType
    ,0 as ImageIndex
    ,0 as IsSync
    FROM   RelayImageMaster*/
    
    
    NSMutableString *ImportQuery=[[NSMutableString alloc]init];
    [ImportQuery appendString:[NSString stringWithFormat:@"INSERT INTO %@ (",anotherTableName]];
    
    for(int i=0;i<FirstTableFields.count;i++){
        
        [ImportQuery appendString:[NSString stringWithFormat:@"%@,",[FirstTableFields objectAtIndex:i]]];

        if(i==FirstTableFields.count-1)
            [ImportQuery deleteCharactersInRange:NSMakeRange([ImportQuery length]-1, 1)];
        
    }
    
    [ImportQuery appendString:@") SELECT "];
    
    
    for(int i=0;i<SecondTableFields.count;i++){
        
        [ImportQuery appendString:[NSString stringWithFormat:@"%@,",[SecondTableFields objectAtIndex:i]]];
        
        if(i==SecondTableFields.count-1)
            [ImportQuery deleteCharactersInRange:NSMakeRange([ImportQuery length]-1, 1)];
        
    }
    
    
    NSArray *allKey=[AliasFields allKeys];
    NSArray *allvalue=[AliasFields allValues];
    
    
    for(int j=0;j<allKey.count;j++){
        
        [ImportQuery appendString:[NSString stringWithFormat:@",'%@' AS %@",[allvalue objectAtIndex:j],[allKey objectAtIndex:j]]];
        
    }
    
    for(int j=0;j<ConditonalFieldsWithInnerQuery.count;j++){
        
        [ImportQuery appendString:[NSString stringWithFormat:@",%@",[ConditonalFieldsWithInnerQuery objectAtIndex:j]]];
        
    }
    
    [ImportQuery appendString:[NSString stringWithFormat:@" FROM %@",firstTableName]];
    
    [self ReleaseObjectsMemoryContent];
    return ImportQuery;
}

-(NSString*)getDataFromTable_Sql:(NSString*)tablename{
    
    
    NSMutableString *SelectQuery=[[NSMutableString alloc]init];
    [SelectQuery appendString:@"SELECT"];
    
    for(int i=0;i<FirstTableFields.count;i++){
        
        NSArray * keys = [[FirstTableFields objectAtIndex:i] allKeys];
        
        if(keys.count>0){
            for (NSString *keyobj in keys)
            {
                [SelectQuery appendString:[NSString stringWithFormat:@" %@ AS %@,",[[FirstTableFields objectAtIndex:i]valueForKey:Kvalues],[keyobj valueForKey:Kvalues]]];
            }
            
        }else{
            
            [SelectQuery appendString:[NSString stringWithFormat:@"%@,",[FirstTableFields objectAtIndex:i]]];
        }
        
        if(i==FirstTableFields.count-1)
            [SelectQuery deleteCharactersInRange:NSMakeRange([SelectQuery length]-1, 1)];
        
    }
    
    [SelectQuery appendString:[NSString stringWithFormat:@" FROM %@ ",tablename]];

    for(int i=0;ConditonalFieldsWithDict.count;i++){
        
         NSDictionary *dict=[ConditonalFieldsWithDict objectAtIndex:i];
        
        [SelectQuery appendString:[NSString stringWithFormat:@"%@=%@ AND",
                                  [dict valueForKey:kFields],
                                  [dict valueForKey:Kvalues]]];
        
        if(i==ConditonalFieldsWithDict.count-1)
            [SelectQuery deleteCharactersInRange:NSMakeRange([SelectQuery length]-3, 3)];

        
    }
    
    [self ReleaseObjectsMemoryContent];
    return SelectQuery;
    
}
-(NSString*)deleteDataFromSql:(NSString*)tableName{
    
    NSMutableString *JoinQuery=[[NSMutableString alloc]init];
    [JoinQuery appendString:[NSString stringWithFormat:@"DELETE FROM %@",tableName]];
    
    
    for(int i=0;i<ConditonalFieldsWithDict.count;i++){
        
        if(i==0)
            [JoinQuery appendString:[NSString stringWithFormat:@" WHERE "]];
        
        
        NSDictionary *dict=[ConditonalFieldsWithDict objectAtIndex:i];
        
        [JoinQuery appendString:[NSString stringWithFormat:@" %@=%@ AND",
                                 [dict valueForKey:kFields],
                                 [dict valueForKey:Kvalues]]];
        
        if(i==ConditonalFieldsWithDict.count-1)
            [JoinQuery deleteCharactersInRange:NSMakeRange([JoinQuery length]-3, 3)];
        
    }
    
    [self ReleaseObjectsMemoryContent];
    return  JoinQuery;
}
-(NSString*)updateTableSql:(NSString*)tableName{
    
     NSMutableString *UpdateQuery=[[NSMutableString alloc]init];
    [UpdateQuery appendString:[NSString stringWithFormat:@"UPDATE  %@ SET ",tableName]];
    
        
    for(int i=0;i<UpdateFieldsWithDict.count;i++){
        
        NSDictionary *dict=[UpdateFieldsWithDict objectAtIndex:i];
        
        [UpdateQuery appendString:[NSString stringWithFormat:@"%@='%@',",
                                 [dict valueForKey:kFields],
                                 [dict valueForKey:Kvalues]]];
        
        if(i==UpdateFieldsWithDict.count-1)
            [UpdateQuery deleteCharactersInRange:NSMakeRange([UpdateQuery length]-1, 1)];
        
    }
    
    
    for(int i=0;i<ConditonalFieldsWithDict.count;i++){
        
        if(i==0)
            [UpdateQuery appendString:[NSString stringWithFormat:@" WHERE "]];
        
        NSDictionary *dict=[ConditonalFieldsWithDict objectAtIndex:i];
        
        [UpdateQuery appendString:[NSString stringWithFormat:@" %@=%@ AND",
                                 [dict valueForKey:kFields],
                                 [dict valueForKey:Kvalues]]];
        
        if(i==ConditonalFieldsWithDict.count-1)
            [UpdateQuery deleteCharactersInRange:NSMakeRange([UpdateQuery length]-3, 3)];
        
    }
    
    [self ReleaseObjectsMemoryContent];
    return  UpdateQuery;
}
-(void)ReleaseObjectsMemoryContent{

    if(FirstTableFields)
        [FirstTableFields removeAllObjects];
    if(SecondTableFields)
        [SecondTableFields removeAllObjects];
    if(ThirdTableFields)
        [ThirdTableFields removeAllObjects];
    if(UnionFields)
        [UnionFields removeAllObjects];
    if(ConditonalFieldsWithDict)
        [ConditonalFieldsWithDict removeAllObjects];
    if(ConditonalFieldsWithInnerQuery)
        [ConditonalFieldsWithInnerQuery removeAllObjects];
    if(UpdateFieldsWithDict)
        [UpdateFieldsWithDict removeAllObjects];
    if(AliasFields)
        AliasFields=nil;
}
@end
