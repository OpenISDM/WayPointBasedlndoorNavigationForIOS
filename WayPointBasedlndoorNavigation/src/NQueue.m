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
 *      This file creates a queue methed and offers to others.
 *
 * File Name:
 *
 *      NQueen.m
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
//  NQueue.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/12.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "NQueue.h"
@interface NQueue ()

// define the array to store data
@property (strong) NSMutableArray *data;
@end

@implementation NQueue

//  initialize
- (instancetype) init{
    if (self = [super init]) {
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

// determine the data array is empty
- (BOOL)isEmpty{
    if ([self.data count] == 0) {
        return YES;
    }
    else{return  NO;}
}

// add new data in array
- (BOOL) add :(id) Object{
    if (type == nil) {type = [Object class];}
    if ([Object class] != type) {
        NSLog(@"ERROR: Trying to add incorrect object");
        return NO;
    }
    if ([self.data count] == 0) {
        [self.data addObject:Object];
        return YES;
    }
    [self.data addObject:Object];
    return YES;
}

// remove data from array
- (BOOL)remove:(id)object{
    NSUInteger i = [self.data indexOfObject:object];
    if (i < -1) {return NO;}
    else {
        [self.data removeObjectAtIndex:i];
        return  YES;
    }
}

// extract data from array
- (id) poll{
    id headObject = [self.data objectAtIndex:0];
    if (headObject) {
        [self.data removeObjectAtIndex:0];
    }
    return headObject;
}

@end
