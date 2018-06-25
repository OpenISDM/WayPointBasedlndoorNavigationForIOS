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
 *      This is the header file containing the function declarations and
 *      variables used in the NavigationViewController.m file.
 *
 * File Name:
 *
 *      NavigationViewController.h
 *
 * Abstract:
 *
 *      The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 *
 * Authors:
 *
 *      Wendy Lu, wendylu@iis.sinica.edu.tw
 *
 */

//
//  NavigationViewController.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/2/8.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
#import "Vertex.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Setting.h"
@import AudioToolbox;
@import CoreLocation;

@protocol XMLDetailParserDelegate <NSObject>
@optional
- (void) returnDataItems:(NSMutableArray*)Array;
@end


@interface NavigationViewController : UIViewController <NSXMLParserDelegate,AVSpeechSynthesizerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) id<XMLDetailParserDelegate> xmldelegate;

// Variables used to record important values--------------------------
// IDs ,Names and Regions of source and destination input by user on home screen
@property (strong, nonatomic) NSString *startText;
@property (strong, nonatomic) NSString *destinationText;
@property (strong, nonatomic) NSString *startID;
@property (strong, nonatomic) NSString *DestinationID;
@property (strong, nonatomic) NSString *starRegion;
@property (strong, nonatomic) NSString *destinationRegion;
@property (strong, nonatomic) Setting *setting;

//@property (strong, nonatomic) CLLocationManager *locationmanager;

- (NSString *) returnstartText;
- (NSString *) returndestinationText;
@end
