//
//  customCell.m
//  databaseProject
//
//  Created by developer on 6/12/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import "customCell.h"
#import "define.h"
@implementation customCell

-(void)setCellData:(NSDictionary*)dictData{
    
    lbldept.text = [dictData valueForKey:kdept];
    lblname.text = [dictData valueForKey:kname];
    
    
}
@end
