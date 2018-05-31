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
 *      variables used in the CompassViewController.m file.
 *
 * File Name:
 *
 *      CompassViewController.h
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
//  CompassViewController.h
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/4/10.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CompassViewController : UIViewController<CLLocationManagerDelegate>

// define target degree
@property (nonatomic) int passedDegree;
@end
