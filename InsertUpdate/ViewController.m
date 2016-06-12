//
//  ViewController.m
//  databaseProject
//
//  Created by developer on 6/11/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import "ViewController.h"
#import "define.h"
#import "customCell.h"
#import "DetailViewController.h"
@interface ViewController ()
{
      NSMutableDictionary *dictDetaildata;
      NSMutableArray  *arrStudentData;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self getDatafromDatabase];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  TableViewDelegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [arrStudentData count];    //count number of row from counting array hear cataGorry is An Array
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    /*
    static NSString *myidentifier = @"Myidentifier";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:myidentifier];
    
    if(cell==nil){
        
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myidentifier];        
        
    }*/
    
    static NSString *simpleTableIdentifier = @"myidentifier";
    
    customCell *cell = (customCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell setCellData:[arrStudentData objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    DetailViewController *detailVc = (DetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"detailSegue"];
    detailVc.arrStudentData = [arrStudentData objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:detailVc animated:YES];
      //[self performSegueWithIdentifier:@"detailSegue" sender:self];
    
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"detailSegue"])
    {
        //if you need to pass data to the next controller do it here
    }
}*/

-(IBAction)btnClicked:(id)sender{
    
    if(dictDetaildata == nil){
        dictDetaildata = [[NSMutableDictionary alloc]init];
    }
    [dictDetaildata setObject:txtname.text  forKey:kname];
    [dictDetaildata setObject:txtDept.text  forKey:kdept];
    [dictDetaildata setObject:txtCourse.text  forKey:kCoures];
    [dictDetaildata setObject:txtResult.text  forKey:Kresult];
    
    
    [[Database databaseSharedInstance] setCompletionHandler:^(NSMutableArray* tempArray)
    {
        [self getDatafromDatabase];
        
    }];
    [Database insertData:dictDetaildata tablename:kstudnetDetail withCallBackHandler:YES];
    
    
}
-(void)getDatafromDatabase{
    
    [[Database databaseSharedInstance] setCompletionHandler:^(NSMutableArray *arr) {
        
        
        arrStudentData = [arr copy];
        
        [tblstudentData reloadData];
        
    }];
    
    [Database getDataFromTable:kstudnetDetail];
}

@end
