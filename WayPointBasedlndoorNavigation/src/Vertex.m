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
 *      This module construct an object represents information of a waypoint.
 *
 * File Name:
 *
 *      Vertex.m
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
- (void) ID :(NSString *) _id{_ID = _id;}
- (NSString *) ID{return _ID;}

#pragma mark - Name Method
- (void) Name:(NSString *)_name{self.name = _name;}
- (NSString *) Name{return self.name;}

#pragma mark - Region Method
- (void) Region :(NSString*) _region{self.region = _region;}
- (NSString *) Region{return self.region;}

#pragma mark - Lat Method
- (void) Lat :(double) _lat{self.lat = _lat;}
- (double) Lat{return self.lat;}

#pragma mark - Lon Method
- (void) Lon :(double) _lon{self.lon = _lon;}
- (double) Lon{return self.lon;}

#pragma mark - Neighbor1 Method
- (void) Neighbor1 :(int) _neighbor1{self.neighbor1 = _neighbor1;}
- (int) Neighbor1{return self.neighbor1;}

#pragma mark - Neighbor2 Method
- (void) Neighbor2 :(int) _neighbor2{self.neighbor2 = _neighbor2;}
- (int) Neighbor2{return _neighbor2;}

#pragma mark - Neighbor3 Method
- (void) Neighbor3 :(int) _neighbor3{self.neighbor3 = _neighbor3;}
- (int) Neighbor3{return self.neighbor3;}

#pragma mark - Neighbor4 Method
- (void) Neighbor4 :(int) _neighbor4{self.neighbor4 = _neighbor4;}
- (int) Neighbor4{return self.neighbor4;}

#pragma mark - Neighbors Method
-(void)Neighbors:(NSMutableArray *)_neighbors{self.neighbors = _neighbors;}
-(NSMutableArray *)Neighbors{return self.neighbors;}

#pragma mark - Category Method
- (void) Category :(NSString*) _category{self.category = _category;}
- (NSString *) Category{return self.category;}

#pragma mark - NodeType Method
- (void) NodeType :(int) _nodeTyoe{self.nodeType = _nodeTyoe;}
- (int) NodeType{return self.nodeType;}

#pragma mark - MainDistance Method
- (void) MinDistance :(double) _mindistance{self.minDistance = _mindistance;}
- (double) MinDistance{return self.minDistance;}

#pragma mark - Adjacencies array Method
- (void) Adjacencies :(NSMutableArray*) edge{self.adjacencies = edge;}
- (NSMutableArray *) Adjacencies{return self.adjacencies;}

#pragma mark - NeighborCount Method
- (int) NeighborCount{
    int count = 0;
    if (self.neighbor1 != 0) {count++;}
    if (self.neighbor2 != 0) {count++;}
    if (self.neighbor3 != 0) {count++;}
    if (self.neighbor4 != 0) {count++;}
    return count;
}

#pragma mark - Previous Method
- (void) Previous :(Vertex*) previous{self.previous = previous;}
-(Vertex *)Previous{return self.previous;}

#pragma mark - ConnectPointID Method
-(void)ConnectPointID:(int)connectPointID{self.connectPointID = connectPointID;}
-(int)ConnectPointID{return self.connectPointID;}
@end
