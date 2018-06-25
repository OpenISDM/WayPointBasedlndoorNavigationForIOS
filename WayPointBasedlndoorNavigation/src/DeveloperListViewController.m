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
 *      This module works as follow:
 *      1. Provides a UI for navigational guidance
 *      2. set up and store developer preference
 *
 * File Name:
 *
 *      DeveloperListViewController.m
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
//  DeveloperListViewController.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/6/22.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "DeveloperListViewController.h"

@interface DeveloperListViewController ()
{
    // define userdefaults
    NSUserDefaults *userDefaults;
}
// define simulation switch
@property (weak, nonatomic) IBOutlet UISwitch *simulationTestSwitch;

@end

@implementation DeveloperListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // initialize userdefaults
    userDefaults = [NSUserDefaults standardUserDefaults];
    [self initSimulationTestSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initSimulationTestSwitch{
    
    // when  the value of "simulationTest" in userdefaults is YES(true)
    // the simulationTestSwitch been setted the state to on.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"simulationTest"] == YES){
        [self.simulationTestSwitch setOn:YES];
    }
    // when  the value of "simulationTest" in userdefaults is NO(false)
    // the simulationTestSwitch been setted the state to off.
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"simulationTest"] == NO){
        [self.simulationTestSwitch setOn:NO];
    }
    
}

- (IBAction)SimulationTestSwitchChange:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"simulationTest"] == YES) {
        [self.simulationTestSwitch setOn:NO];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"simulationTest"] == NO){
        [self.simulationTestSwitch setOn:YES];
    }
    
    [userDefaults setBool:self.simulationTestSwitch.on forKey:@"simulationTest"];
    [userDefaults synchronize];
}
@end
