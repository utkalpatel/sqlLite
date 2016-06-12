//
//  DetailViewController.m
//  databaseProject
//
//  Created by developer on 6/12/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import "DetailViewController.h"
#import "define.h"
@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize arrStudentData;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    lblname.text = [arrStudentData  valueForKey:kname];
    lbldept.text = [arrStudentData valueForKey:kdept];
    lblCourse.text = [arrStudentData valueForKey:kCoures];
    lblresult.text= [arrStudentData valueForKey:Kresult];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
