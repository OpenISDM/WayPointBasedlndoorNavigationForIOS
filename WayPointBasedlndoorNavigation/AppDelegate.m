/*
    Copyright (c) 2018 Academia Sinica, Institute of Information Science

    License:

        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.

    Project Name:

        WayPointBasedIndoorNavigationForIOS

    File Description:

        This file controls the states of this app to do something

    File Name:

        AppDelegate.m

    Abstract:

        The WayPointBasedIndoorNavigationForIOS is smartphone UI for
        iOS user.

    Authors:

        Wendy Lu, wendylu@iis.sinica.edu.tw
 
*/

//
//  AppDelegate.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/1/31.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    [session setActive:YES error:&error];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // store userDefaults data when application does not on the view.
    [NSKeyedArchiver archiveRootObject:[NSUserDefaults standardUserDefaults] toFile:@"userDefaults.archive"];
    NSLog(@"close");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}


@end
