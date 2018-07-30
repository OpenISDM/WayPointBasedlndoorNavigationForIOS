/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This module construct an object to represent information of a navigation subgraph
 
   File Name:
 
        NavigationSubgraph.m
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
*/

//
//  NavigationSubgraph.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/5/14.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "NavigationSubgraph.h"
#import "Vertex.h"
#import "Edge.h"
#import "GeoCalculation.h"

@implementation NavigationSubgraph

-(instancetype)init{
    if (self = [super init]) {
        self.verticesInSubgraph = [NSMutableDictionary new];
    }
    return self;
}

-(void)addEdge{
    for ( id key in self.verticesInSubgraph) {
        Vertex *vertex = [self.verticesInSubgraph objectForKey:key];
        NSMutableArray *listOfEdge = [NSMutableArray new];
        
        for (int i=0; i<vertex.Neighbors.count; i++) {
            Edge *e = [[Edge alloc] initEdge:[self.verticesInSubgraph objectForKey:[vertex.Neighbors objectAtIndex:i]] weight:[[GeoCalculation alloc] getDistance:vertex :[self.verticesInSubgraph objectForKey:[vertex.Neighbors objectAtIndex:i]]]];
            [listOfEdge addObject:e];
        }
        [[self.verticesInSubgraph objectForKey:key] Adjacencies:listOfEdge];
         NSLog(@"RRR:%@",vertex.ID);

    }
}

@end
