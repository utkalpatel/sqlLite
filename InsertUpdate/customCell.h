//
//  customCell.h
//  databaseProject
//
//  Created by developer on 6/12/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customCell : UITableViewCell
{
    
    IBOutlet UILabel *lblname;
    IBOutlet UILabel *lbldept;
    IBOutlet UILabel *lblresult;
}

-(void)setCellData:(NSDictionary*)dictData;

@end

