/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This is the header file containing the function declarations and
        variables used in the ViewController.m file.
 
   File Name:
 
        ViewController.h
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */

//
//  ViewController.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/1/31.
//  Copyright © 2018年 Wendy. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PointChooseViewController.h"
#import "NavigationViewController.h"
#import "Setting.h"
#import "DeveloperListViewController.h"

@interface ViewController : UIViewController <InputDelegate>

// Receive the start or destination point and button tag
@property (strong, nonatomic) NSMutableArray *ctrlArray;

// Store ID of start and destination point
@property (strong, nonatomic)NSString *startID;
@property (strong, nonatomic)NSString *destinationID;

// Store Region of start and destination point
@property (strong, nonatomic)NSString *startRegion;
@property (strong, nonatomic)NSString *destinationRegion;

// Define the start point button ID
@property (weak, nonatomic) IBOutlet UIButton *startButton;
// Define the destination point button ID
@property (weak, nonatomic) IBOutlet UIButton *destinationpButton;
// Define the preference setting segmented control
@property (weak, nonatomic) IBOutlet UISegmentedControl *setting;


// Define the start point button action when the click
- (IBAction)startpbtnAction:(id)sender;
// Define the destination point button action when the click
- (IBAction)destinationpbtnAction:(id)sender;
// Define the start to navigation button action when the click
- (IBAction)startNavButton:(id)sender;
// Define the preference-Setting segmented action when the chose
- (IBAction)preferenceChange:(id)sender;
// Define the user preference button action when the click
- (IBAction)userPreferenceAction:(id)sender;
// Define the developer list display when the button click
- (IBAction)versionButtonAction:(id)sender;

@end

