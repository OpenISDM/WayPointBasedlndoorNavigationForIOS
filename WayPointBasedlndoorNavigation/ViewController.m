/*
 * Copyright (c) 2018 Academia Sinica, Institute of Information Science
 *
 * License:
 *
 *      GPL 3.0 : The content of this file is subject to the terms and
 *      conditions defined in file 'COPYING.txt', which is part of this source
 *      code package.
 *
 * Project Name:
 *
 *      WayPointBasedIndoorNavigationForIOS
 *
 * File Description:
 *
 *      This ViewController controls home screen.
 *
 * File Name:
 *
 *      ViewController.m
 *
 * Abstract:
 *
 *        The WayPointBasedIndoorNavigationForIOS is smartphone UI for
 *        iOS user.
 *
 * Authors:
 *
 *      Wendy Lu, wendylu@iis.sinica.edu.tw
 *
 */

//
//  ViewController.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/1/31.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "ViewController.h"

#define APP_VERSION @"1.0.0"

@interface ViewController (){
    int settingFlag;
    Setting *setting;
}

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    setting = [Setting new];
    
    // set version number on main page
    self.versionLabel.text = [NSString stringWithFormat:@"version:%@",APP_VERSION];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Receive and distinguish the name of point from PointChooseViewController.m */
#pragma mark - get point value from ChoosePointPage
-(void)backWithPoint:(NSMutableArray *)str{
    
    // Receive point name information mutablearray
    self.ctrlArray = str;
    
    /* Distinguish the start point name */
    if ([[self.ctrlArray objectAtIndex:0] isEqualToString:@"start"]){
        
        // set point name to the title of start point button
        [self.startButton setTitle:[self.ctrlArray objectAtIndex:1] forState:UIControlStateNormal];
        
        // reset title color of start point button
        [self.startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        // store the ID of the start point
        self.startID = [self.ctrlArray objectAtIndex:2];
        
        // store the Region of th e start point
        self.startRegion = [self.ctrlArray objectAtIndex:3];
    }
    
    /* Distinguish the destination point name */
    else if ([[self.ctrlArray objectAtIndex:0] isEqualToString:@"destination"])
    {
        // set point name to the title of destination point button
        [self.destinationpButton setTitle:[self.ctrlArray objectAtIndex:1] forState:UIControlStateNormal];
        
        // reset title color of destination point button
        [self.destinationpButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        // store the ID of the destination point
        self.destinationID = [self.ctrlArray objectAtIndex:2];
        
        // store the Region of the destination point
        self.destinationRegion = [self.ctrlArray objectAtIndex:3];
    }
}

#pragma mark - the action when button click
/* when start point button click */
- (IBAction)startpbtnAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PointChooseViewController *inputStartValue = [storyboard instantiateViewControllerWithIdentifier:@"ChoosePointPage"];
    
    //make the  start button flag
    inputStartValue.btnFlag = @"start";
    
    inputStartValue.delegate = self;
    
    //turn to ChoosePointPage page
    [self.navigationController pushViewController:inputStartValue animated:YES];
}

/* when destination point button click */
- (IBAction)destinationpbtnAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PointChooseViewController *inputStartValue = [storyboard instantiateViewControllerWithIdentifier:@"ChoosePointPage"];
    
    //make the  deatination button flag
    inputStartValue.btnFlag = @"destination";
    
    inputStartValue.delegate = self;
    
    //turn to ChoosePointPage page
    [self.navigationController pushViewController:inputStartValue animated:YES];

}

/* when start navigation button click */
- (IBAction)startNavButton:(id)sender {
    
    /* if user doesn't input starting and destination point,the alertview shows. */
    if ([self.startButton.titleLabel.text isEqualToString:@"Choose a start point"] || [self.destinationpButton.titleLabel.text isEqualToString:@"Choose a destination"]){
        
        //Creat the error alert view
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"empty error!" message:@"Please input the start and destination point!" preferredStyle:UIAlertControllerStyleAlert];
        
        //set the "ok" button of the alert view
        UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        //Add the "ok" button to the alert view
        [errorAlert addAction:okAlertAction];
        
        //To show the alert view
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
    
    /* if user input starting and destination point,starting navigation page */
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        NavigationViewController *startNavPage = [storyboard instantiateViewControllerWithIdentifier:@"StartNavPage"];
        
        // pass the start and destination point name to navigation page
        startNavPage.startText = self.startButton.titleLabel.text;
        startNavPage.destinationText = self.destinationpButton.titleLabel.text;
        
        // pass the ID of the start and destination point to navigation page
        startNavPage.startID = self.startID;
        startNavPage.DestinationID = self.destinationID;
        
        // pass the Region of the start and destination point to navigation page
        startNavPage.starRegion = self.startRegion;
        startNavPage.destinationRegion = self.destinationRegion;
        
        // pass the value of the preference setting to navigation page
        startNavPage.setting = setting;
        
        // turn page to navigation page
        [self.navigationController pushViewController:startNavPage animated:YES];

    }
    
}

// preference setting option
- (IBAction)preferenceChange:(id)sender {
    switch (self.setting.selectedSegmentIndex) {
        case 0:
            [setting setMobilityValue:1];
            break;
        case 1:
            [setting setMobilityValue:1];
            break;
        case 2:
            [setting setMobilityValue:2];
            break;
        default:
            break;
    }
}
@end
