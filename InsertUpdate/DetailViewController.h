//
//  DetailViewController.h
//  databaseProject
//
//  Created by developer on 6/12/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
{
    
    IBOutlet UILabel *lblname;
    IBOutlet UILabel *lbldept;
    IBOutlet UILabel *lblCourse;
    IBOutlet UILabel *lblresult;
}
@property(nonatomic,strong)NSMutableArray *arrStudentData;
@end
