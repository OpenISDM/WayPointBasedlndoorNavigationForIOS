/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This module contains the methods to calculate
        the bearing and distance of two point with their
        latitude and longitude are given
 
   File Name:
 
        GeoCalculation.m
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */

//
//  GeoCalculation.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/3/8.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "GeoCalculation.h"
#define RADIUS_OF_EARTH 6371
#define toRadians(angle) ((angle)/180.0*M_PI)
#define toDegrees(radian) ((radian)*(180.0/M_PI))

#define FRONT_DIRECTION_SMALL_LOWER_BOUND 0
#define FRONT_DIRECTION_SMALL_UPPER_BOUND 5
#define RIGHT_DIRECTION_LOWER_BOUND 75
#define RIGHT_DIRECTION_UPPER_BOUND 105
#define BACK_DIRECTION_LOWER_BOUND 175
#define BACK_DIRECTION_UPPER_BOUND 185
#define LEFT_DIRECTION_LOWER_BOUND 255
#define LEFT_DIRECTION_UPPER_BOUND 285
#define FRONT_DIRECTION_BIG_LOWER_BOUND 355
#define FRONT_DIRECTION_BIG_UPPER_BOUND 360

@implementation GeoCalculation

// Coupute the angle of next step
-(int)getBearingFromCoordinate:(Vertex *)A :(Vertex *)B{
    double latA = [[[NSMeasurement alloc] initWithDoubleValue:A.Lat unit:NSUnitAngle.radians] doubleValue];
    double longA = [[[NSMeasurement alloc] initWithDoubleValue:A.Lon unit:NSUnitAngle.radians] doubleValue];
    double latB = [[[NSMeasurement alloc] initWithDoubleValue:B.Lat unit:NSUnitAngle.radians] doubleValue];
    double longB = [[[NSMeasurement alloc] initWithDoubleValue:B.Lon unit:NSUnitAngle.radians] doubleValue];
    
    double deltaLon = longB - longA;
    
    double y = sin(deltaLon) * cos(latB);
    double x = cos(latA) * sin(latB) - sin(latA) * cos(latB) * cos(deltaLon);
    
    double bearingFromAToB = toDegrees(atan2(y, x));
    bearingFromAToB = fmod(bearingFromAToB+360, 360);
    
    return (int)rint(bearingFromAToB);
}

// get the turn direction at Vertex B, when moving from Vertex A to Vertex B to
// Vertex C
-(NSString *)getDirectionFromBearing:(Vertex *)A :(Vertex *)B :(Vertex *)C{
    
    // direction result
    NSString *direction = nil;
    
    // get true bearing from A to B
    int bearingFromAToB = [self getBearingFromCoordinate:A :B];
    
    // get true bearing from B to C
    int bearingFromBToC = [self getBearingFromCoordinate:B :C];
    
    // get the difference of two bearing
    int angle = bearingFromBToC - bearingFromAToB;
    
    // make angle a positive number
    if (angle < 0) {angle += 360;}
    
    // Difference interval to determine the true direction
    if (angle >=FRONT_DIRECTION_SMALL_LOWER_BOUND && angle <= FRONT_DIRECTION_SMALL_UPPER_BOUND) {direction = @"front";}
    else if (angle >= FRONT_DIRECTION_SMALL_UPPER_BOUND && angle <= RIGHT_DIRECTION_LOWER_BOUND) {direction = @"frontRight";}
    else if (angle >= RIGHT_DIRECTION_LOWER_BOUND && angle <=RIGHT_DIRECTION_UPPER_BOUND) {direction = @"right";}
    else if (angle >= RIGHT_DIRECTION_UPPER_BOUND && angle <= BACK_DIRECTION_LOWER_BOUND) {direction = @"rearRight";}
    else if (angle >= BACK_DIRECTION_LOWER_BOUND && angle <= BACK_DIRECTION_UPPER_BOUND) {direction = @"rear";}
    else if (angle >= BACK_DIRECTION_UPPER_BOUND && angle <= LEFT_DIRECTION_LOWER_BOUND) {direction = @"rearLeft";}
    else if (angle >= LEFT_DIRECTION_LOWER_BOUND && angle <= LEFT_DIRECTION_UPPER_BOUND) {direction = @"left";}
    else if (angle >= LEFT_DIRECTION_UPPER_BOUND && angle <= FRONT_DIRECTION_BIG_LOWER_BOUND) {direction = @"frontLeft";}
    else if (angle >= FRONT_DIRECTION_BIG_LOWER_BOUND && angle <= FRONT_DIRECTION_BIG_UPPER_BOUND) {direction = @"front";}
    NSLog(@"bearingFromAToB(%i) - bearingFromBToC(%i) = angle(%i), direction is %@", bearingFromAToB, bearingFromBToC, angle, direction);
    return direction;
}

// Coupute the distance of between two point
- (int)getDistance :(Vertex *) vertex1 :(Vertex *) vertex2{
    
    double lat1 = [vertex1 Lat];
    double lon1 = [vertex1 Lon];
    double lat2 = [vertex2 Lat];
    double lon2 = [vertex2 Lon];
    
    double latDistance = toRadians(lat2-lat1);
    double lonDistance = toRadians(lon2-lon1);
    
    double a = pow(sin(latDistance/2), 2)+cos(toRadians(lat1))*cos(toRadians(lat2))*pow(sin(lonDistance/2), 2);
    double c = 2*atan2(sqrt(a), sqrt(1-a));
    double distance = RADIUS_OF_EARTH*c*1000;
    return (int)rint(distance);
}

-(double)toRadians :(double) number{return number * M_PI / 180;}

@end
