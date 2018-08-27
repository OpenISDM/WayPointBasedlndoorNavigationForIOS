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
        variables used in the PointChooseViewController.m file.
 
   File Name:
 
        PointChooseViewController.h
 
   Abstract:
 
        The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */

//
//  PointChooseViewController.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/2/6.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PointChooseViewController;

/* Creat the delegate protocal that when back home page, pass the land mark
   name to home page */
@protocol InputDelegate <NSObject>
- (void) backWithPoint:(NSMutableArray *) str;
@end

/* Creat the delegate protocal that when XML parser done */
@protocol XMLParserDelegate <NSObject>
@optional
- (void) returnedDataItems:(NSMutableArray*)Array;
@end

@interface PointChooseViewController : UIViewController <NSXMLParserDelegate>

// Define the place choosing drop down list button
@property (weak, nonatomic) IBOutlet UIButton *placeButton;

// Define the tableview of the place drop down list
@property (weak, nonatomic) IBOutlet UITableView *placeTableview;
// Define the point name tableview
@property (weak, nonatomic) IBOutlet UITableView *pointTableview;

// Define the array of the storing place name
@property (strong, nonatomic) NSArray *placeArray;

// Define the mutablearray of the storing landmark name data
@property (strong, nonatomic) NSMutableDictionary *pointdataArray;

// Define the information array for pass to homepage
@property (strong, nonatomic) NSMutableArray *inputArray;

// Define the name of the selecting cell title
@property (strong, nonatomic) NSString *intputValue;

// Define the string of to receive the button tag (start/destination)
@property (strong, nonatomic) NSString *btnFlag;

// Define the indexpath of the storing place array index
@property (strong, nonatomic) NSIndexPath *placeIndexPath;

// Define the delegate of the pass landmark name to home page
@property (nonatomic, weak) id<InputDelegate> delegate;

// Define the delegate of the XML parser
@property (weak, nonatomic) id<XMLParserDelegate> xmldelegate;

// Define the action when placename button click
- (IBAction)placeBtnAction:(id)sender;

@end
