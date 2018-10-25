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
        variables used in the XMLDataParser.m file.
 
   File Name:
 
        XMLDataParser.h
 
   Abstract:
 
        The WayPointBasedrIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */

//
//  XMLDataParser.h
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/2/12.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vertex.h"
#import "Edge.h"
#import "Region.h"
#import "NavigationSubgraph.h"


@interface XMLDataParser : NSObject <NSXMLParserDelegate>

// def the all data of indoorpoint information
@property (strong, nonatomic) NSMutableDictionary *regionData;
@property (strong, nonatomic) NSMutableArray *categoryList;
@property (strong, nonatomic) NSMutableDictionary *categoryData;
@property (strong, nonatomic) NSMutableArray *localArray;
@property (strong, nonatomic) NSMutableArray *groupBeaconArray;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSMutableArray *routingData;
@property (strong, nonatomic) NSMutableArray *Adjacencies;
@property (strong, nonatomic) NSMutableDictionary *uuidData;


- (void)startXMLParser: (NSString*) filename;

- (void)startXMLParserForPoint: (nullable NSMutableArray*) filenames fileName: (nullable NSString *) filename;

- (void)startXMLParserForUUID: (NSString*) filename;

- (NSMutableDictionary *)returnRegionData;

- (NSMutableArray *)returnLocalData;
- (NSMutableArray *)returnGroupBeaconArray;

- (NSMutableArray *) returnRoutingData;

-(NSMutableArray *)CategoryList;

- (NSMutableDictionary*) returnCategoryData;

- (NSMutableDictionary*) returnUUIDData;

@end
