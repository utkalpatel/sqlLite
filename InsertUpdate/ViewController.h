//
//  ViewController.h
//  databaseProject
//
//  Created by developer on 6/11/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

{
    IBOutlet UITableView *tblstudentData;
    IBOutlet UITextField *txtname;
    IBOutlet UITextField *txtDept;
    IBOutlet UITextField  *txtCourse;
    IBOutlet UITextField *txtResult;
    Database *database;
    
}
-(IBAction)btnClicked:(id)sender;
@end

