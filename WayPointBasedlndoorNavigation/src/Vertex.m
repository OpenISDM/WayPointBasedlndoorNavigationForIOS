/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This module construct an object represents information of a waypoint.
 
   File Name:
 
        Vertex.m
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */

//
//  Vertex.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/5.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "Vertex.h"
#define INFINITY HUGE_VALF


@interface Vertex()
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (strong, nonatomic) NSString *region;
@property (strong, nonatomic) NSString *category;
@property (nonatomic) int nodeType;
@property (nonatomic) int connectPointID;
@property (strong, nonatomic) NSMutableArray *neighbors;
@property (nonatomic) int neighbor1;
@property (nonatomic) int neighbor2;
@property (nonatomic) int neighbor3;
@property (nonatomic) int neighbor4;
@property (strong, nonatomic) NSMutableArray *adjacencies;
@property (nonatomic) double minDistance;
@property (strong, nonatomic) Vertex *previous;
@end

@implementation Vertex
// Initialize basis
- (instancetype) init{
    if (self = [super init]) {
        _name = [[NSString alloc] init];
        _region = [[NSString alloc] init];
        _category = [[NSString alloc] init];
        _adjacencies = [[NSMutableArray alloc] init];
        _minDistance = INFINITY;
    }
    return self;
}

// Initialize the object with the point information of Route
-(instancetype)initForRouteComputation:(NSString *)ID Name:(NSString *)name Lat:(double)lat Lon:(double)lon Neighbors:(NSMutableArray *)neighbors Region:(NSString *)region Category:(NSString *)category NodeType:(int)nodeType ConnectPoint:(int)connectPointId{
    if (self = [super init]) {
        self.ID = ID;
        self.name = name;
        self.lat = lat;
        self.lon = lon;
        self.neighbors = neighbors;
        self.region = region;
        self.category = category;
        self.nodeType = nodeType;
        self.connectPointID = connectPointId;
        self.adjacencies = [[NSMutableArray alloc] init];
        self.minDistance = INFINITY;
    }
    return self;
}

// Initialize the object with UUID information
-(instancetype) initForUIDisplay :(NSString*) ID Name:(NSString*) name Region:(NSString*) region Category:(NSString*) category{
    if (self = [super init]) {
        self.ID = ID;
        self.name = name;
        self.region = region;
        self.category = category;
    }
    return self;
}

#pragma mark - ID Method
// Set ID
- (void) ID :(NSString *) _id{_ID = _id;}
// Get ID
- (NSString *) ID{return _ID;}

#pragma mark - Name Method
// Set Name
- (void) Name:(NSString *)_name{self.name = _name;}
// Get Name
- (NSString *) Name{return self.name;}

#pragma mark - Region Method
// Set Region
- (void) Region :(NSString*) _region{self.region = _region;}
// Get Region
- (NSString *) Region{return self.region;}

#pragma mark - Lat Method
// Set Latitude
- (void) Lat :(double) _lat{self.lat = _lat;}
// Get Latitude
- (double) Lat{return self.lat;}

#pragma mark - Lon Method
// Set Longitude
- (void) Lon :(double) _lon{self.lon = _lon;}
// Get Longitude
- (double) Lon{return self.lon;}

#pragma mark - Neighbor1 Method
// Set the 1st Neighbor
- (void) Neighbor1 :(int) _neighbor1{self.neighbor1 = _neighbor1;}
// Get the 1st Neighbor
- (int) Neighbor1{return self.neighbor1;}

#pragma mark - Neighbor2 Method
// Set the 2nd Neighbor
- (void) Neighbor2 :(int) _neighbor2{self.neighbor2 = _neighbor2;}
// Get the 2nd Neighbor
- (int) Neighbor2{return _neighbor2;}

#pragma mark - Neighbor3 Method
// Set the 3th Neighbor
- (void) Neighbor3 :(int) _neighbor3{self.neighbor3 = _neighbor3;}
// Get the 3th Neighbor
- (int) Neighbor3{return self.neighbor3;}

#pragma mark - Neighbor4 Method
// Set the 4th Neighbor
- (void) Neighbor4 :(int) _neighbor4{self.neighbor4 = _neighbor4;}
// Get the 4th Neighbor
- (int) Neighbor4{return self.neighbor4;}

#pragma mark - Neighbors Method
// Set Neighbors array
-(void)Neighbors:(NSMutableArray *)_neighbors{self.neighbors = _neighbors;}
// Get Neighbors array
-(NSMutableArray *)Neighbors{return self.neighbors;}

#pragma mark - Category Method
// Set Category
- (void) Category :(NSString*) _category{self.category = _category;}
// Get Category
- (NSString *) Category{return self.category;}

#pragma mark - NodeType Method
// Set NodeType
- (void) NodeType :(int) _nodeTyoe{self.nodeType = _nodeTyoe;}
// Get NodeType
- (int) NodeType{return self.nodeType;}

#pragma mark - MainDistance Method
// Set the Minimum Distance
- (void) MinDistance :(double) _mindistance{self.minDistance = _mindistance;}
// Set the Minimum Distance
- (double) MinDistance{return self.minDistance;}

#pragma mark - Adjacencies array Method
// Set Adjacencies arrray
- (void) Adjacencies :(NSMutableArray*) edge{self.adjacencies = edge;}
// Get Adjacencies arrray
- (NSMutableArray *) Adjacencies{return self.adjacencies;}

#pragma mark - NeighborCount Method
// Get the count of neighbors array
- (int) NeighborCount{
    int count = 0;
    if (self.neighbor1 != 0) {count++;}
    if (self.neighbor2 != 0) {count++;}
    if (self.neighbor3 != 0) {count++;}
    if (self.neighbor4 != 0) {count++;}
    return count;
}

#pragma mark - Previous Method
// Set Previous
- (void) Previous :(Vertex*) previous{self.previous = previous;}
// Get Previous
-(Vertex *)Previous{return self.previous;}

#pragma mark - ConnectPointID Method
// Set ConnectPointID
-(void)ConnectPointID:(int)connectPointID{self.connectPointID = connectPointID;}
// Get ConnectPointID
-(int)ConnectPointID{return self.connectPointID;}
@end
