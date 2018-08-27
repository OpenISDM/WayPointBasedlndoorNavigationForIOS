/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This module works as follow:
        1. Provides a UI for user setting of navigator
        2. set up and store user preference
 
   File Name:
 
        PreferenceViewController.m
 
   Abstract:
 
          The WayPointBasedIndoorNavigationForIOS is smartphone UI for
          iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
 
 */

//
//  PreferenceViewController.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/6/5.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "PreferenceViewController.h"

@interface PreferenceViewController (){
    NSUserDefaults *userDefaults;
}

// define alertview button display in navigator page of switch
@property (weak, nonatomic) IBOutlet UISwitch *alertButtonUISwitch;

@end

@implementation PreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do initialize the alertview button UIswitch
    [self initForAlertviewButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIswitch initialize
-(void)initForAlertviewButton{
    
    // initialize userDefaults
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    // when  the value of "alertviewButton" in user preference is YES(true)
    // the alertButtonUISwitch been setted the state to on.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertviewButton"] == YES) {
        [self.alertButtonUISwitch setOn:YES];
    }
    // when  the value of "alertviewButton" in user preference is NO(false)
    // the alertButtonUISwitch been setted the state to off.
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertviewButton"] == NO){
        [self.alertButtonUISwitch setOn:NO];
    }
}



#pragma mark - UIswitch action
// when click alertview Button switch
- (IBAction)alertviewButtonUISwitchChange:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertviewButton"] == YES) {
        [self.alertButtonUISwitch setOn:NO];
    }
    else{
        [self.alertButtonUISwitch setOn:YES];
    }
    
    //store user data in phone memory
    [userDefaults setBool:self.alertButtonUISwitch.on forKey:@"alertviewButton"];
    [userDefaults synchronize];
}
@end
