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
        variables used in the Region.m file.
 
   File Name:
 
        Region.h
 
   Abstract:
 
        The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
*/

//
//  Region.h
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/5/10.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Region : NSObject

- (instancetype) init;
- (instancetype) initForRegion :(NSString*) name Neighbors:(NSMutableArray*) neighbors LocationsOfRegion:(NSMutableArray*) locationOfRegion Elevation:(int) elevation;
- (NSString*) Name;
- (NSMutableArray*) Neighbors;
- (NSMutableArray*) LocationOfRegion;
- (void) LocationOfRegion :(NSMutableArray*) locationOfRegion;
- (int) Elevation;
- (BOOL) Visited;
- (void) Visited :(BOOL) visited;

@end
