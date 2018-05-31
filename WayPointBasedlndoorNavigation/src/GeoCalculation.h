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
 *      variables used in the GeoCalculation.m file.
 *
 * File Name:
 *
 *      GeoCalculation.h
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
//  GeoCalculation.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/8.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vertex.h"

@interface GeoCalculation : NSObject


- (int)getBearingFromCoordinate :(Vertex *) A :(Vertex *) B;
- (NSString*)getDirectionFromBearing :(Vertex *) A :(Vertex *) B :(Vertex *) C;
- (int)getDistance :(Vertex *) vertex1 :(Vertex *) vertex2;

@end
