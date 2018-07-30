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
        variables used in the Vertex.m file.
 
   File Name:
 
        Vertex.h
 
   Abstract:
 
        The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */


//
//  Vertex.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/5.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Edge.h"

@interface Vertex : NSObject

- (instancetype) init;
- (instancetype) initForRouteComputation :(NSString*) ID Name:(NSString*) name Lat:(double) lat Lon:(double) lon Neighbors:(NSMutableArray*) neighbors Region:(NSString*) region Category:(NSString*) category NodeType:(int) nodeType ConnectPoint:(int) connectPointId;
-(instancetype) initForUIDisplay :(NSString*) ID Name:(NSString*) name Region:(NSString*) region Category:(NSString*) category;

#pragma ID Method
- (void) ID :(NSString *) _id;
- (NSString *) ID;

#pragma mark - Name Method
- (void) Name :(NSString*) _name;
- (NSString *) Name;

#pragma mark - Region Method
- (void) Region :(NSString*) _region;
- (NSString *) Region;

#pragma mark - Lat Method
- (void) Lat :(double) _lat;
- (double) Lat;

#pragma mark - Lon Method
- (void) Lon :(double) _lon;
- (double) Lon;

#pragma mark - Neighbor1 Method
- (void) Neighbor1 :(int) _neighbor1;
- (int) Neighbor1;

#pragma mark - Neighbor2 Method
- (void) Neighbor2 :(int) _neighbor2;
- (int) Neighbor2;

#pragma mark - Neighbor3 Method
- (void) Neighbor3 :(int) _neighbor3;
- (int) Neighbor3;

#pragma mark - Neighbor4 Method
- (void) Neighbor4 :(int) _neighbor4;
- (int) Neighbor4;

#pragma mark - Neighbors Method
- (void) Neighbors :(NSMutableArray*) _neighbors;
- (NSMutableArray*) Neighbors ;

#pragma mark - Category Method
- (void) Category :(NSString*) _category;
- (NSString *) Category;

#pragma mark - NodeType Method
- (void) NodeType :(int) _nodeTyoe;
- (int) NodeType;

#pragma mark - MainDistance Method
- (void) MinDistance :(double) _mindistance;
- (double) MinDistance;

#pragma mark - Adjacencies array Method
- (void) Adjacencies :(NSMutableArray *) edge;
- (NSMutableArray *) Adjacencies;

#pragma mark - NeighborCount Method
- (int) NeighborCount;

#pragma mark - Previous Method
- (void) Previous :(Vertex*) previous;
- (Vertex *) Previous;

#pragma mark - ConnectPointID Method
- (void) ConnectPointID :(int) connectPointID;
- (int) ConnectPointID;
@end
