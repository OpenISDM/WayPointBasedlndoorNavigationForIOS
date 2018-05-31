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
 *      This is the header file containing the function declarations and
 *      variables used in the Setting.m file.
 *
 * File Name:
 *
 *      Setting.h
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
//  Setting.h
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/4/30.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject
- (int) getMobilityValue;
- (void) setMobilityValue :(int) m;
- (NSString *) getFileName;
- (void) setFileName :(NSString*) f;
@end
