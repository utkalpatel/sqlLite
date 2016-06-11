//
//  ViewController.m
//  databaseProject
//
//  Created by developer on 6/11/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

#import "ViewController.h"
#import "define.h"
@interface ViewController ()
{
      NSMutableDictionary *dictDetaildata;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  TableViewDelegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section;{
    return 12;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    static NSString *myidentifier = @"Myidentifier";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:myidentifier];
    
    if(cell==nil){
        
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myidentifier];        
        
    }
    
    return cell;
}
-(IBAction)btnClicked:(id)sender{
    
    if(dictDetaildata == nil){
        dictDetaildata = [[NSMutableDictionary alloc]init];
    }
    
    
    
 
    [dictDetaildata setObject:txtname.text  forKey:kname];
    [dictDetaildata setObject:txtDept.text  forKey:kdept];
    [dictDetaildata setObject:txtCourse.text  forKey:kCoures];
    [dictDetaildata setObject:txtResult.text  forKey:Kresult];
    
    [Database insertData:dictDetaildata tablename:kstudnetDetail withCallBackHandler:NO];
    
}


@end
