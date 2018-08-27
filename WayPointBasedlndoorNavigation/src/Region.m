/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This module construct an object represents information of a region.
 
   File Name:
 
        Region.m
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
*/

//
//  Region.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/5/10.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "Region.h"

@interface Region()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *neighbors;
@property (strong, nonatomic) NSMutableArray *locationOfRegion;
@property (nonatomic) int elevation;
@property (nonatomic) BOOL visited;

@end

@implementation Region

// Initialize basis
-(instancetype)init{
    if (self = [super init]) {
        self.name = [NSString new];
        self.neighbors = [NSMutableArray new];
        self.locationOfRegion = [NSMutableArray new];
        self.visited = NO;
    }
    return self;
}

// Initialize the object with Region information
-(instancetype)initForRegion :(NSString *)name Neighbors:(NSMutableArray *)neighbors LocationsOfRegion:(NSMutableArray *)locationOfRegion Elevation:(int)elevation{
   
        self.name = name;
        self.neighbors = neighbors;
        self.locationOfRegion = locationOfRegion;
        self.elevation = elevation;
        self.visited = NO;
    
    return self;
}

// Get Name
-(NSString *)Name{return self.name;}

// Get Neighbors array
-(NSMutableArray *)Neighbors{return self.neighbors;}

// Get Location Of Region
-(NSMutableArray *)LocationOfRegion{return self.locationOfRegion;}
// Set Location Of Region
-(void)LocationOfRegion:(NSMutableArray *)locationOfRegion{self.locationOfRegion = locationOfRegion;}

// Get Elevation
-(int)Elevation{return self.elevation;}

// Get Visited
-(BOOL)Visited{return self.visited;}
// Set Visited
-(void)Visited:(BOOL)visited{self.visited = visited;}

@end
