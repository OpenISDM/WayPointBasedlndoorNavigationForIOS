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
 *      variables used in the Edge.m file.
 *
 * File Name:
 *
 *      Edge.h
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
//  Edge.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/13.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Vertex;

@interface Edge : NSObject
- (instancetype) initEdge :(Vertex*) _target weight:(double) _weight;
- (Vertex *) Target;
- (double) Weight;
@end
