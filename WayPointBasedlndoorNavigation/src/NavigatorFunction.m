/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This file contains the program to navigation operation and distance
        judgment from rssi value
 
   File Name:
 
        NavigatorFunction.m
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
        Paul Chang, paulchang@iis.sinica.edu.tw
 
*/

//
//  NavigatorFunction.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/7/16.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "NavigatorFunction.h"

@interface NavigatorFunction (){
    
}


@end


@implementation NavigatorFunction
{
    //****** private object ******
    // to store data from "SettingPList.plist"
    NSDictionary *settingPList;
    
    // def object of xmlParser
    XMLDataParser *xmlDataPerser;
    
    //def object of setting
    Setting *setting;
    
    // def boolin object of reset flag
    BOOL resetFlag;
    
    // def object of GeoCalculation
    GeoCalculation *geoCalculation;
    //*****************************
}

// initialize the objects
-(instancetype)init{
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"SettingPList.plist"];
        settingPList = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    return self;
}


#pragma mark - Navigator
// public function--------------------------------------------------------------
// initialize the objects for computing path of navigation
-(instancetype)initForNavigationPathWithPreferenceSetting:(Setting*) preferenceSetting{
    if (self = [super init]) {
        // initialize object
        xmlDataPerser = [XMLDataParser new];
        self.regionData = [NSMutableDictionary new];
        self.regionPath = [NSMutableArray new];
        self.locationData = [NSMutableArray new];
        self.navigationPath = [NSMutableArray new];
        self.UUIDtoNameDict = [NSMutableDictionary new];
        self.messageFromInstructionHandler = @"";
        self.messageFromCurrentPositionHandler = @"";
        self.messageFromWalkedPointHandle = @"";
        setting = preferenceSetting;
        resetFlag = NO;
        geoCalculation = [GeoCalculation new];
        self.walkWaypoint = 0;
    }
    return self;
}

// Preprocessor-----------------------------------------------------------------
#define NORMAL_WAYPOINT 0
#define ELEVATOR_WAYPOINT 1
#define STAIRWELL_WAYPOINT 2
#define CONNECTPOINT 3

#define FRONT @"front"
#define LEFT @"left"
#define FRONT_LEFT @"frontLeft"
#define REAR_LEFT @"rearLeft"
#define RIGHT @"right"
#define FRONT_RIGHT @"frontRight"
#define REAR_RIGHT @"rearRight"
#define ELEVATOR @"elevator"
#define ELEVATORING @"elevatoring"
#define STAIR @"stair"
#define STAIRING @"stairing"
#define ARRIVED @"arrived"
#define WRONG @"wrong"
// -----------------------------------------------------------------------------

// load the infomation data from building map file
-(void)readBuildingWaypointDataForBuildingName:(NSString*) buildingName SourceRegion:(NSString*) sourceRegion DestinationRegion:(NSString*) destinationRegion {
    // read the xml file
    [xmlDataPerser startXMLParser:buildingName];
    
    // load region data from region graph
    self.regionData = [xmlDataPerser returnRegionData];
    // load location data(Vertex) from region graph
    self.locationData = [xmlDataPerser returnLocalData];
    
    // switch vertex_array to dict for store all data which in graph
    for (int i=0; i<self.locationData.count; i++) {
        [self.UUIDtoNameDict setObject:[[self.locationData objectAtIndex:i] Name] forKey:[[self.locationData objectAtIndex:i] ID]];
    }
    
    // regionPath for storing Region objects represent the regions that the user passes by from source to destination
    self.regionPath = [self getRegionPathWithSourceRegion:sourceRegion DestinationRegion:destinationRegion];
    // an array of string of region name in regionPath
    NSMutableArray *regionPathID = [NSMutableArray new];
    
    for (int i = 0; i < self.regionPath.count; i++) {
        [regionPathID addObject:[[self.regionPath objectAtIndex:i] Name]];
    }
    
    // load waypoint data from the navigation subgraphs according to the
    // regionPathID
    [xmlDataPerser startXMLParserForPoint:regionPathID fileName:nil];
    self.navigationGraph = [xmlDataPerser returnRoutingData];
}

// Compute navigation path with the IDs of source point and destination point
-(void)computeNavigationPathForSourceID:(NSString*) sourceID DestinationID:(NSString*) destinationID{
    // obtain the Vertex objects that represent source point and destination point
    Vertex *sourceVertex = [[[self.navigationGraph objectAtIndex:0] verticesInSubgraph] objectForKey:sourceID];
    Vertex *destinationVertex = [[[self.navigationGraph objectAtIndex:self.navigationGraph.count-1] verticesInSubgraph] objectForKey:destinationID];
    // temporary variable to record connectPointID
    int connectPointID;
    
    // if navigation in the same region
    if (self.navigationGraph.count == 1) {
        // preform typical dijkstra's algorithm with two given Vertex objects
        self.navigationPath = [self computeDijkstraShortestPathWithSourceVertex:sourceVertex DestinaitonVertex:destinationVertex];
    }
    // navigation between several regions
    else{
        // compute N-1 navigation paths for each regioni,where N is the number
        // of region to travel
        for (int i = 0; i < self.navigationGraph.count-1; i++) {
            // a destination vertex for each region
            Vertex *destinationOfARegion = nil;
            
            // the source vertex becomes a normal waypoint
            [[[[self.navigationGraph objectAtIndex:i] verticesInSubgraph] objectForKey:sourceID] NodeType:NORMAL_WAYPOINT];
            // if the elevation of the next region to travel is same as current region
            if ([[self.regionPath objectAtIndex:i] Elevation] == [[self.regionPath objectAtIndex:i+1] Elevation]) {
                // compute a path to a transfer point of current region return
                // the transfer point
                destinationOfARegion = [self computePathToTraversePointWithSourceVertex:[[[self.navigationGraph objectAtIndex:i] verticesInSubgraph] objectForKey:sourceID] SameElevator:YES NextRegion:i+1];
              
                // sourceID is updated with the ID of transfer node for the
                // next computation since the transfer point
                sourceID = destinationOfARegion.ID;
            }
            // if the elevation of the next region to travel is different from the current region
            else if ([[self.regionPath objectAtIndex:i] Elevation] != [[self.regionPath objectAtIndex:i+1] Elevation]){
                // compute a path to a transfer point (elevator or stairwell)
                // of current region return the transfer point
                destinationOfARegion = [self computePathToTraversePointWithSourceVertex:[[[self.navigationGraph objectAtIndex:i] verticesInSubgraph] objectForKey:sourceID] SameElevator:NO NextRegion:0];
                // get the connectPointID of the transfer node
                connectPointID = destinationOfARegion.ConnectPointID;
                
                // find the transfer node with the same connectPointID in the
                // next region where elevation is different from the current region
                for (id key in [[self.navigationGraph objectAtIndex:i+1] verticesInSubgraph]) {
                    Vertex *v = [[[self.navigationGraph objectAtIndex:i+1] verticesInSubgraph] objectForKey:key];
                    
                    if (v.ConnectPointID == connectPointID) {
                        sourceID = v.ID;
                        break;
                    }
                }
            }
            // add up all the navigation paths into one
            [self.navigationPath addObjectsFromArray:[self getShortertPathWithDestination:destinationOfARegion]];
        }
        // compute navigation path in the last region
        NSMutableArray *pathInLastRegion = [self computeDijkstraShortestPathWithSourceVertex:[[[self.navigationGraph objectAtIndex:self.navigationGraph.count-1] verticesInSubgraph] objectForKey:sourceID] DestinaitonVertex:destinationVertex];
        // complete the navigation path
        [self.navigationPath addObjectsFromArray:pathInLastRegion];
        
        // remove duplicated waypoints which are used connecting points in same elevation
        for (int i =1; i < self.navigationPath.count; i++) {
            if ([[[self.navigationPath objectAtIndex:i] ID] isEqualToString:[[self.navigationPath objectAtIndex:i-1] ID]]) {
                [self.navigationPath removeObjectAtIndex:i];
            }
        }
    }
}

// Reset navigation path
-(NSString*)resetNavigationPathWithFileName:(NSString*) fileName SourceID:(NSString*) sourceID{
    xmlDataPerser = [XMLDataParser new];
    [xmlDataPerser startXMLParserForPoint:nil fileName:fileName];
    NSMutableArray *allData = [NSMutableArray new];
    allData = [xmlDataPerser returnRoutingData];
    
    for (Vertex *v in allData) {
        if ([sourceID caseInsensitiveCompare:v.ID] == NSOrderedSame) {
            resetFlag = YES;
            NSString *sourceRegion = v.Region;
            return sourceRegion;
            break;
        }
    }
    return @"";
}

// Navigation thread to compare with current beacon's Name whether match to navigationPath's Name
-(void)navigation {
    // if the received ID matches the ID of the next waypoint in the navigation path
    BOOL isBeaconNameSame = [[[self.navigationPath objectAtIndex:0] Name] isEqualToString:[self.UUIDtoNameDict objectForKey:[self.currentLBeaconID uppercaseStringWithLocale:[NSLocale currentLocale]]]];
    //if ([[[self.navigationPath objectAtIndex:0] ID] caseInsensitiveCompare:self.currentLBeaconID] == NSOrderedSame) {
    if (isBeaconNameSame) {
        // currentPositionHandler get the message of currently matched waypoint name
        self.messageFromCurrentPositionHandler = [[self.navigationPath objectAtIndex:0] Name];
        
        // if the navigation path has more than three waypoints to travel
        if (self.navigationPath.count >= 3) {
            // if the next two waypoints are in the same region as the current
            // waypoint get the turn direction at the next waypoint
            if ([[[self.navigationPath objectAtIndex:0] Region] isEqualToString:[[self.navigationPath objectAtIndex:1] Region]] && [[[self.navigationPath objectAtIndex:1] Region] isEqualToString:[[self.navigationPath objectAtIndex:2] Region]]) {
                NSLog(@"testtoelevator1");

                self.messageFromInstructionHandler = [self->geoCalculation getDirectionFromBearing:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1] :[self.navigationPath objectAtIndex:2]];
            }
            // if the next two waypoints are not in the same regioin means that
            // the next waypoint is the last waypoint of the region travel
            else if (![[[self.navigationPath objectAtIndex:1] Region] isEqualToString:[[self.navigationPath objectAtIndex:2] Region]]) {
                NSLog(@"testtoelevator2");
                if ([[self.navigationPath objectAtIndex:1] NodeType] == ELEVATOR_WAYPOINT && [[self.navigationPath objectAtIndex:2] NodeType] == ELEVATOR_WAYPOINT) {
                    self.messageFromInstructionHandler = ELEVATOR;
                }
                else if ([[self.navigationPath objectAtIndex:1] NodeType] == STAIRWELL_WAYPOINT && [[self.navigationPath objectAtIndex:2] NodeType] == STAIRWELL_WAYPOINT) {
                    self.messageFromInstructionHandler = STAIR;
                }
                else {
                    self.messageFromInstructionHandler = FRONT;
                }
            }
            // if the current waypoint and the next waypoint are not in the same region transfeer through elevator or stairwell
            else if (![[[self.navigationPath objectAtIndex:0] Region] isEqualToString:[[self.navigationPath objectAtIndex:1] Region]]){
                NSLog(@"testtoelevator3");
                if ([[self.navigationPath objectAtIndex:0] NodeType] == ELEVATOR_WAYPOINT) {
                     NSLog(@"elevator comming2");
                    self.messageFromInstructionHandler = ELEVATORING;
                }
                else if ([[self.navigationPath objectAtIndex:0] NodeType] == STAIRWELL_WAYPOINT) {
                    self.messageFromInstructionHandler = STAIRING;
                }
                else if ([[self.navigationPath objectAtIndex:0] NodeType] == CONNECTPOINT) {
                    self.messageFromInstructionHandler = [self->geoCalculation getDirectionFromBearing:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1] :[self.navigationPath objectAtIndex:2]];
                }
            }
        }
        // if there are two waypoints left in the navigation path
        else if (self.navigationPath.count == 2) {
            // if the current waypoint and the next waypoint are not in the same region
            if (![[[self.navigationPath objectAtIndex:0] Region] isEqualToString:[[self.navigationPath objectAtIndex:1] Region]]) {
                if ([[self.navigationPath objectAtIndex:0] NodeType] == ELEVATOR_WAYPOINT) {
                    self.messageFromInstructionHandler = ELEVATOR;
                }
                else if ([[self.navigationPath objectAtIndex:0] NodeType] == STAIRWELL_WAYPOINT) {
                    self.messageFromInstructionHandler = STAIR;
                }
            }
            // if go strainght to final waypoint
            else {
                self.messageFromInstructionHandler = FRONT;
            }
        }
        // if there is only one waypoint left, the user arrived
        else if (self.navigationPath.count == 1){
            self.messageFromInstructionHandler = ARRIVED;
        }
        
        // every time the received ID is match the user is considered to travel
        // one more waypoint
        self.walkWaypoint++;
        // "WalkedPoint"  method  get the message of number of waypoint has
        // been travel in a region
        self.messageFromWalkedPointHandle = [NSString stringWithFormat:@"%i",self.walkWaypoint];
    }
    // if the received ID does not match the ID of waypoint in the navigation path
    // else if ([[[self.navigationPath objectAtIndex:0] ID] caseInsensitiveCompare:self.currentLBeaconID] != NSOrderedSame) {
    else {
        NSLog(@"current LBeacon ID is %@\n", self.currentLBeaconID);
        // set "wrong" to the "messageFromInstructionHandler" object
        self.messageFromInstructionHandler = WRONG;
    }
}

// ----------------------- private function -----------------------
// Get the region path, which means the travels order of region,
// by performing shortest path algorithm on an unweighted connected graph
// (Region Graph)
-(NSMutableArray*)getRegionPathWithSourceRegion:(NSString*) sourceRegion DestinationRegion:(NSString*) destinationRegion {
    
    // define and initialize a object for queue
    NQueue *queue = [NQueue new];
    // define and initialize a dictionary object for storing region
    NSMutableDictionary *path = [NSMutableDictionary new];
    
    [queue add:[self.regionData objectForKey:sourceRegion]];
    [path setObject:@"" forKey:[[self.regionData objectForKey:sourceRegion] Name]];
    [[self.regionData objectForKey:sourceRegion] Visited:YES];
    
    while (!queue.isEmpty) {
        Region *regionNode = queue.poll;
        for (int i = 0; i < regionNode.Neighbors.count; i++) {
            NSString *nameOfNeighbor = [regionNode.Neighbors objectAtIndex:i];
            if ([self.regionData objectForKey:nameOfNeighbor] != nil && ![[self.regionData objectForKey:nameOfNeighbor] Visited]) {
                [queue add:[self.regionData objectForKey:nameOfNeighbor]];
                [path setObject:regionNode forKey:[[self.regionData objectForKey:nameOfNeighbor] Name]];
                
                [[self.regionData objectForKey:nameOfNeighbor] Visited:YES];
            }
        }
    }
    NSMutableArray *shortestRegionPath = [NSMutableArray new];
    
    while (true) {
        [shortestRegionPath addObject:[self.regionData objectForKey:destinationRegion]];
        
        if (![[[self.regionData objectForKey:destinationRegion] Name] isEqualToString:sourceRegion]) {
            destinationRegion = [[path objectForKey:[[self.regionData objectForKey:destinationRegion] Name]] Name];
        }
        else {
            break;
        }
    }
    shortestRegionPath = [NSMutableArray arrayWithArray:[[shortestRegionPath reverseObjectEnumerator] allObjects]];
    return shortestRegionPath;
}

// Compute a shortest path with given starting point  and destination
-(NSMutableArray*) computeDijkstraShortestPathWithSourceVertex:(Vertex*) sourceVertex DestinaitonVertex:(Vertex*) destinationVertex{
    [sourceVertex MinDistance:0];
    NQueue *queue = [NQueue new];
    [queue add:sourceVertex];
    
    while (!queue.isEmpty) {
        Vertex *vertex = [queue poll];
        
        // stop searching when reach the destination node
        if ([[vertex ID] isEqualToString:[destinationVertex ID]]) {
            break;
        }
        // visit each edge that is adjacent to v
        for (Edge *_e in vertex.Adjacencies) {
            Vertex *target = [_e Target];
            double weight = _e.Weight;
            double distanceThroughU = vertex.MinDistance + weight;
            
            if (distanceThroughU < target.MinDistance) {
                [queue remove:target];
                [target MinDistance:distanceThroughU];
                [target Previous:vertex];
                [queue add:target];
            }
        }
    }
    return [self getShortertPathWithDestination:destinationVertex];
}

// Compute a shortest path from a given source point to a transfer node(e.g.
// elevator, stairwell)
-(Vertex*) computePathToTraversePointWithSourceVertex:(Vertex*) sourceVertex SameElevator:(BOOL) sameElevatorFlag NextRegion:(int) nextRegion{
    [sourceVertex MinDistance:0];
    NQueue *queue = [NQueue new];
    [queue add:sourceVertex];
    
    while (!queue.isEmpty) {
        Vertex *u = [queue poll];
        
        // visite each edge exiting u
        for (Edge *e in u.Adjacencies) {
            Vertex *v = e.Target;
            double weight = e.Weight;
            double distanceThroughU = u.MinDistance +weight;
            
            if (distanceThroughU < v.MinDistance) {
                [queue remove:v];
                [v MinDistance:distanceThroughU];
                [v Previous:u];
                [queue add:v];
            }
            if (sameElevatorFlag == YES && v.NodeType == CONNECTPOINT) {
                if ([[[self.navigationGraph objectAtIndex:nextRegion] verticesInSubgraph] objectForKey:v.ID] != nil) {
                    return  v;
                }
            }
            else if (sameElevatorFlag == NO && v.NodeType == setting.getMobilityValue){
                return v;
            }
        }
    }
    return sourceVertex;
}

// get shorteset path by traversing previous waypoint back to the source
-(NSMutableArray*) getShortertPathWithDestination:(Vertex*) destinationVertex{
    NSMutableArray *path = [NSMutableArray new];
    for (Vertex *vertex = destinationVertex; vertex != nil; vertex = vertex.Previous) {
        [path addObject:vertex];
    }
    
    // reverse path to get correct order
    path = [NSMutableArray arrayWithArray:[[path reverseObjectEnumerator] allObjects]];
    return path;
}


// #pragma mark - Navigator thread


#pragma mark - RSSI

// Preprocessor-----------------------------------------------------------------
/* Store the thresholds of RSSI from "SettingPList.plist" file
   The distance from beacon to user phone:
    0m = -40 ~ -47
    1m = -48 ~ -52
    2m = -53 ~ -57
    3m = -58 ~ -60
    4m = -61 ~
   Developer can reset the thresholds of RSSI to "SettingPList.plist" file
*/
#define RSSI_0_MAX [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"0M"] objectForKey:@"Max"] intValue]
#define RSSI_0_MIN [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"0M"] objectForKey:@"Min"] intValue]
#define RSSI_1_MAX [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"1M"] objectForKey:@"Max"] intValue]
#define RSSI_1_MIN [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"1M"] objectForKey:@"Min"] intValue]
#define RSSI_2_MAX [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"2M"] objectForKey:@"Max"] intValue]
#define RSSI_2_MIN [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"2M"] objectForKey:@"Min"] intValue]
#define RSSI_3_MAX [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"3M"] objectForKey:@"Max"] intValue]
#define RSSI_3_MIN [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"3M"] objectForKey:@"Min"] intValue]
#define RSSI_4 [[[[settingPList objectForKey:@"RSSIValue"] objectForKey:@"4M"] objectForKey:@"Max"] intValue]
// -----------------------------------------------------------------------------

// Use RSSI value to judgment distance
-(NSInteger)RSSIJudgment:(CLBeacon *)beacon {
    NSInteger rssi = [beacon rssi];
    NSInteger distance = 4;
    
    // if rssi > the 0M rssi minimum thresholds
    if (rssi >= (int)RSSI_0_MIN && rssi != 0) {
        NSLog(@"t11");
        distance = 0;
    }
    // if rssi > the 1M rssi minimum thresholds
    else if (rssi >= (int)RSSI_1_MIN && rssi != 0) {
        NSLog(@"t12");
        distance = 1;
    }
    return distance;
}
@end
