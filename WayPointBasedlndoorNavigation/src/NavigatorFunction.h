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
        variables used in the NavigatorFunction.m file.
 
   File Name:
 
        NavigatorFunction.h
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
        Paul Chang, paulchang@iis.sinica.edu.tw
 
*/

//
//  NavigatorFunction.h
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/7/16.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLDataParser.h"
#import "NQueue.h"
#import "Region.h"
#import "Vertex.h"
#import "Edge.h"
#import "Setting.h"
#import "GeoCalculation.h"


@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFunction : NSObject

// start----Variables used to store routing data--------------------------------
// Dictionary for storing region data
@property (strong, nonatomic) NSMutableDictionary *regionData;

// An array of Region object storing the information of region that will be traveled through
@property (strong, nonatomic) NSMutableArray *regionPath;

// An array of NavigationSubgraph object representing a Navigation Graph
@property (strong, nonatomic) NSMutableArray *navigationGraph;

// An array of Vertex object representing a navigation path
@property (strong, nonatomic) NSMutableArray *navigationPath;
// A dictionary to save UUID & Name
@property (strong, nonatomic) NSMutableDictionary *UUIDtoNameDict;
// A array to save all beacons information
@property (strong, nonatomic) NSMutableArray *VertexArray;

// An array of Location object representing a location data
@property (strong, nonatomic) NSMutableArray *locationData;
// An array of Group Beacons
@property (strong, nonatomic) NSMutableArray *groupBeaconArray;

// A string of LBeacon ID object representing current site.
@property (strong, nonatomic) NSString *currentLBeaconID;

// The strings of message recode the instruction, current position, and walkedpoint.
@property (strong, nonatomic) NSString *messageFromInstructionHandler;
@property (strong, nonatomic) NSString *messageFromCurrentPositionHandler;
@property (strong, nonatomic) NSString *messageFromWalkedPointHandle;
@property (nonatomic) int walkWaypoint;

// end----Variables used to store routing data----------------------------------

#pragma mark - Navigator
// initialize objects
-(instancetype)initForNavigationPathWithPreferenceSetting:(Setting*) preferenceSetting;
// read needed waypoint data from building graph file
-(void)readBuildingWaypointDataForBuildingName:(NSString*) buildingName SourceRegion:(NSString*) sourceRegion DestinationRegion:(NSString*) destinationRegion;
// compute the navigation path of the needed waypoint
-(void)computeNavigationPathForSourceID:(NSString*) sourceID DestinationID:(NSString*) destinationID;
// reset the source point of navigation path
-(NSString*)resetNavigationPathWithFileName:(NSString*) fileName SourceID:(NSString*) sourceID;
// match the current point and the waypoint of navigation path
-(void)navigation;

// compute the direction for restart navigation
-(NSString*)computeDirectionForReNavigation:(Vertex*) previousVLocation andCurrentVLocation:(Vertex*) currentVLocation andNextVLocation:(Vertex*) nextVLocation;

#pragma mark - RSSI
-(NSInteger)RSSIJudgment :(CLBeacon *) beacon;
@end

NS_ASSUME_NONNULL_END
