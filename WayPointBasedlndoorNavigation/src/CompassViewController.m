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
 *      This file creates compass for let user to regulate position.
 *
 * File Name:
 *
 *      CompassViewController.m
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
//  CompassViewController.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/4/10.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "CompassViewController.h"
#define toRadians(angle) ((angle)/180.0*M_PI) //angle to radian

@interface CompassViewController (){
    
    // device sensor manager
    CLLocationManager *locationManager;
    // recode the compass historical angle
    float historyDegree;
    // rotate animation of picture
    CABasicAnimation *rotateAnimate;
    
    CLLocationDirection magDev;
    
    int degreeHeader;
}

// define the heading label
@property (weak, nonatomic) IBOutlet UILabel *tvHeading;
// define the display assembly compass picture
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCompass;
// define the label to show degree
@property (weak, nonatomic) IBOutlet UILabel *degreeText;

@end

@implementation CompassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize device sensor manager and delegate
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    // initialize compass historical angle
    historyDegree = 0.0;
    
    // initialize UI image and set up conpass picture on imageview
    UIImage *imageCompass = [UIImage new];
    imageCompass = [UIImage imageNamed:@"compass.png"];
    self.imageViewCompass.image = imageCompass;
    
    /* set up the parameter of the rotate animation */
     // set up the axis of the rotating
    rotateAnimate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
     // set up the duration of animation
    rotateAnimate.duration = 0.21;
    
     // set up the repeat number of times
    rotateAnimate.repeatCount =0;
    
    // start up device sensor manager
    [locationManager startUpdatingHeading];

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

#pragma mark - LocationManager
// Receive the direction of the device
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    int degreeHeader;
    
    // Determining whether effective towards
    if (newHeading.headingAccuracy < 0) {
        NSLog(@"error towards");
        return;
    }
    
    // get the direction of the device
    CLLocationDirection degree = [newHeading trueHeading];
    CLLocationDirection degree2 = [newHeading magneticHeading];
    
    // get the magnetic deviation of the region
    magDev = [newHeading headingAccuracy];
    NSLog(@"true:%.2f_mag:%.2f_diff:%.2f",degree,degree2,degree-degree2);
    
    // true bearing to magnetic bearing
    degreeHeader = self.passedDegree;
//    degreeHeader -= (degree-degree2);
    
    // set up the needed degree on the label
    self.degreeText.text = [NSString stringWithFormat:@"Turn to %i degree",degreeHeader];
    
    // set up the present of the user rotate
    self.tvHeading.text = [NSString stringWithFormat:@"%.1f degrees",degree];
    
    // the storyboard go back to previous page when the present degree and the degree of the target are same value
    if ((int)degree == degreeHeader) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    /* do compass picture rotate animation */
    rotateAnimate.fromValue = [NSNumber numberWithFloat:toRadians(historyDegree)];
    rotateAnimate.toValue = [NSNumber numberWithFloat:toRadians(-degree+degreeHeader)];
    rotateAnimate.removedOnCompletion = NO;
    rotateAnimate.fillMode = kCAFillModeForwards;
    [self.imageViewCompass.layer addAnimation:rotateAnimate forKey:@"rotateLayer"];
    
    // recode present degree to as the historical degree
    historyDegree = -degree+degreeHeader;
    
}

@end
