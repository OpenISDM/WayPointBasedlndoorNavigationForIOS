/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This module works as follow:
        1. Provides a UI for waypoint lists
        2. Returns the information of choosed waypoint
 
   File Name:
 
        PointChooseViewController.m
 
   Abstract:
 
        The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
*/

//
//  PointChooseViewController.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/2/6.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "PointChooseViewController.h"
#import "XMLDataParser.h"
#import "CustomTableViewCell.h"

@interface PointChooseViewController ()<UITableViewDataSource,UITextViewDelegate,NSXMLParserDelegate>{
    
    // Implementation XMLDataParser.m
    XMLDataParser *XML;
    
}

@end

@implementation PointChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initial  inputarray
    self.inputArray = [[NSMutableArray alloc]initWithObjects:@"a",@"b", nil];
    
    // Initial XMLDataParser
    XML = [[XMLDataParser alloc] init];
    
    // start XML Parser
    [XML startXMLParser:@"buildingA"];
    
    // Receive to parser region data
    self.placeArray = [XML CategoryList];
    
    // Receive to parser landmark data
    self.pointdataArray = [XML returnCategoryData];
    
    //initial button title
    [self.placeButton setTitle:[self.placeArray objectAtIndex:0] forState:UIControlStateNormal];
    
    //initial cell select
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.placeTableview selectRowAtIndexPath:cellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    NSLog(@"we:%@",[self.pointdataArray objectForKey:@"Category1"]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - tableview setting
/* set quantity of tableview cell */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    /* specified tableview */
     // set the cell quantity of pull down menu
    if (tableView == self.placeTableview){
        return [self.placeArray count];
    }
     // set the  cell quantity of tableview
    else if (tableView == self.pointTableview){
        return [[self.pointdataArray objectForKey:[self.placeArray objectAtIndex:self.placeIndexPath.item]] count];
    }
    return 0;
}

/* The function of setting the content of tableview cell label */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /*  Specified tableview */
     // pulldown menu
    if (tableView == self.placeTableview){
        
        // set the id of cell that in the tableview
        static NSString *cellId = @"placecell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        // Check the tableview cell is empty
        if (cell == nil){
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        // Set the content of the tableview cell
        cell.textLabel.text = [self.placeArray objectAtIndex:indexPath.row];
        return cell;
    }
     // tableview
    else if (tableView == self.pointTableview){
        
        // set the id of cell that in the tableview
        static NSString *cellId = @"pointcell";
        CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        // Check the tableview cell is empty
        if (cell == nil){
            cell =[[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        // Set the cell title, cell detail and point ID  of the tableview cell
        cell.textLabel.text = [[[self.pointdataArray objectForKey:[self.placeArray objectAtIndex:self.placeIndexPath.item]] objectAtIndex:indexPath.row] Name];
        cell.detailTextLabel.text = [[[self.pointdataArray objectForKey:[self.placeArray objectAtIndex:self.placeIndexPath.item]] objectAtIndex:indexPath.row] Region];
        cell.idPoint.text = [[[self.pointdataArray objectForKey:[self.placeArray objectAtIndex:self.placeIndexPath.item]] objectAtIndex:indexPath.row] ID];
        return cell;
    }
    
    return nil;
}

/* Read the selection cell information */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /*  Specified tableview */
     // pulldown menu
    if (tableView == self.placeTableview){
        
        // store selecting cell
        UITableViewCell *cell = [self.placeTableview cellForRowAtIndexPath:indexPath];
        
        // store the indexpath of selecting cell
        self.placeIndexPath = indexPath;
        // Reload pointTableview
        [self.pointTableview reloadData];
        // Set place drop dowm list button title
        [self.placeButton setTitle:cell.textLabel.text forState:UIControlStateNormal];
        // Hide the placeTableview
        self.placeTableview.hidden = YES;
    }
     // tableview
    else if (tableView == self.pointTableview){
        
        // store selecting cell
        CustomTableViewCell *cell = [self.pointTableview cellForRowAtIndexPath:indexPath];
        // store the content of selection cell label text
        self.intputValue = cell.textLabel.text;
        NSString *inputRegion = cell.detailTextLabel.text;
        NSString *inputID = cell.idPoint.text;
        
        // store the content of button tag and point name that pass the home
        // page
        [self.inputArray replaceObjectAtIndex:0 withObject:self.btnFlag];
        [self.inputArray replaceObjectAtIndex:1 withObject:self.intputValue];
        [self.inputArray addObject:inputID];
        [self.inputArray addObject:inputRegion];
        
        [self.delegate backWithPoint:self.inputArray];
        // back the home page
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - the action of button
// when click the place button the pulldown menu hide or display
- (IBAction)placeBtnAction:(id)sender {
    if (self.placeTableview.hidden == YES){
        self.placeTableview.hidden = NO;
    }
    else{
        self.placeTableview.hidden = YES;
    }
}
@end
