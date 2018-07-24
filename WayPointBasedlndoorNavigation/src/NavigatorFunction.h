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

// start----Variables used to store routing data--------------------------------------------------------
// Dictionary for storing region data
@property (strong, nonatomic) NSMutableDictionary *regionData;

// An array of Region object storing the information of region that will be traveled through
@property (strong, nonatomic) NSMutableArray *regionPath;

// An array of NavigationSubgraph object representing a Navigation Graph
@property (strong, nonatomic) NSMutableArray *navigationGraph;

// An array of Vertex object representing a navigation path
@property (strong, nonatomic) NSMutableArray *navigationPath;

// An array of Location object representing a location data
@property (strong, nonatomic) NSMutableArray *locationData;

// A string of LBeacon ID object representing current site.
@property (strong, nonatomic) NSString *currentLBeaconID;

@property (strong, nonatomic) NSString *messageFromInstructionHandler;
@property (strong, nonatomic) NSString *messageFromCurrentPositionHandler;
@property (strong, nonatomic) NSString *messageFromWalkedPointHandle;
@property (nonatomic) int walkWaypoint;

// end----Variables used to store routing data----------------------------------------------------------

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
#pragma mark - RSSI
-(NSInteger)RSSIJudgment :(CLBeacon *) beacon;
@end

NS_ASSUME_NONNULL_END
