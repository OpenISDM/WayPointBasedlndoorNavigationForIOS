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
 *      This module represent an edge of a vertex with given target vertex and weight
 *
 * File Name:
 *
 *      Edge.m
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
//  Edge.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/13.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "Edge.h"
#import "Vertex.h"

@interface Edge()
@property (strong, nonatomic) Vertex* target;
@property (nonatomic) double weight;
@end

@implementation Edge

- (instancetype) init{
    if (self = [super init]) {
        self.target = [[Vertex alloc] init];
    }
    return self;
}

- (instancetype) initEdge :(Vertex *) _target weight:(double) _weight{
    if (self = [super init]) {
        self.target = _target;
        self.weight = _weight;
    }
    return self;
}

- (Vertex *) Target{return self.target;}

- (double) Weight{return self.weight;}
@end
