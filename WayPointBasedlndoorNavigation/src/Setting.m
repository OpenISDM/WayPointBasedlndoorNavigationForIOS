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
 *      This module work as preference setting function
 *
 * File Name:
 *
 *      Setting.m
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
//  Setting.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/4/30.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "Setting.h"
@interface Setting(){
    int mobilityValue;
    NSString *filename;
}
@end

@implementation Setting
-(instancetype)init{
    mobilityValue = 1;
    filename = @"buildingA";
    return self;
}

-(int)getMobilityValue{
    return mobilityValue;
}
-(void)setMobilityValue:(int)m{
    mobilityValue = m;
}
-(NSString *)getFileName{
    return filename;
}
-(void)setFileName:(NSString *)f{
    filename = f;
}
@end
