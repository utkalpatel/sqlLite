//
//  QueryBuilder.h
//  HEKXO Relay
//
//  Created by Utkal Patel on 12/3/15.
//  Copyright © 2015 Utkal Patel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryBuilder : NSObject

@property(nonatomic,strong)NSMutableArray *FirstTableFields;
@property(nonatomic,strong)NSMutableArray *SecondTableFields;
@property(nonatomic,strong)NSMutableArray *ThirdTableFields;
@property(nonatomic,strong)NSMutableArray *UnionFields;
@property(nonatomic,strong)NSMutableArray *ConditonalFieldsWithInnerQuery;
@property(nonatomic,strong)NSMutableArray *UpdateFieldsWithDict;
@property(nonatomic,strong)NSMutableArray *ConditonalFieldsWithDict;
@property(nonatomic,strong)NSDictionary   *AliasFields;


-(NSMutableString*)getJoinQueryfor:(NSString*)firstTable  secondtable:(NSString*)secondtable;
//Import Data from one table to another table.
-(NSString*)importdataFrom:(NSString*)firstTableName ToanotherTable:(NSString*)anotherTableName;

-(NSString*)getDataFromTable_Sql:(NSString*)tablename;

-(NSString*)deleteDataFromSql:(NSString*)tableName;

-(NSString*)updateTableSql:(NSString*)tableName;
@end
