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
        1. Provides a UI for navigational guidance
        2. Background listening to Lbeacon signals
 
   File Name:
 
        NavigationViewController.m
 
   Abstract:
 
        The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
        Paul Chang, paulchang@iis.sinica.edu.tw
 
 */

//
//  NavigationViewController.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/2/8.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "NavigationViewController.h"
#import "XMLDataParser.h"
#import "Vertex.h"
#import "NQueue.h"
#import "Edge.h"
#import "Setting.h"
#import "GeoCalculation.h"
#import "CompassViewController.h"
#import "ViewController.h"
#import "NavigatorFunction.h"

#pragma mark - Arg,Txt and Image Define
#define NORMAL_WAYPOINT 0
#define ELEVATOR_WAYPOINT 1
#define STAIRWELL_WAYPOINT 2
#define CONNECTPOINT 3
#define ARRIVED_NOTIFIER 0
#define WRONGWAY_NOTIFIER 1
#define MAKETURN_NOTIFIER 2
#define ALERTVIEW_DISMISS_TIME 3.0f

#define FILENAME @"buildingA"
#define RSSI_THRESHOLD -65

#define FRONT @"front"
#define LEFT @"left"
#define FRONT_LEFT @"frontLeft"
#define REAR_LEFT @"rearLeft"
#define RIGHT @"right"
#define FRONT_RIGHT @"frontRight"
#define REAR_RIGHT @"rearRight"
#define ELEVATOR @"elevator"
#define ELEVATORING @"elevatoring"
#define ELEVATORED @"elevatored"
#define STAIR @"stair"
#define STAIRING @"stairing"
#define ARRIVED @"arrived"
#define WRONG @"wrong"

#define GO_STRAIGHT_ABOUT @"直走約"
#define THEN_GO_STRAIGHT @"繼續直走"
#define THEN_TURN_LEFT @"然後向左轉"
#define THEN_TURN_RIGHT @"然後向右轉"
#define THEN_TURN_FRONT_LEFT @"然後向左前方轉"
#define THEN_TURN_FRONT_RIGHT @"然後向右前方轉"
#define THEN_TURN_REAR_LEFT @"然後向左後方轉"
#define THEN_TURN_REAR_RIGHT @"然後向右後方轉"
#define THEN_TAKE_ELEVATOR @"然後搭電梯"
#define THEN_WALK_UP_STAIR @"然後走樓梯"
#define WAIT_FOR_ELEVATOR @"電梯中請稍候"
#define TAKE_ELEVATOR_TO(i) [NSString stringWithFormat:@"%@ %@ %@",@"搭至",i,@"樓層"]
#define OUT_OF_ELEVATOR @"出電梯"
#define WALK_UP_STAIR @"爬樓梯中"

#define YOU_HAVE_ARRIVE @"抵達目的地"
#define YOU_WILL_ARRIVE @"即將地達目的地"
#define GET_LOST @"你走錯路了"
#define METERS(i) [NSString stringWithFormat:@"%d %@",i,@"公尺"]
#define PLEASE_GO_STRAIGHT @"請直走"
#define PLEASE_TURN_LEFT @"請左轉"
#define PLEASE_TURN_RIGHT @"請右轉"
#define PLEASE_TURN_FRONT_LEFT @"請向左前方轉"
#define PLEASE_TURN_FRONT_RIGHT @"請向右前方轉"
#define PLEASE_TURN_REAR_LEFT @"請向左後方轉"
#define PLEASE_TURN_REAR_RIGHT @"請向右後方轉"
#define PLEASE_TAKE_ELEVATOR @"請搭電梯"
#define PLEASE_OUT_OF_ELEVATOR @"請出電梯"
#define PLEASE_WALK_UP_STAIR @"請走樓梯"

#define IMAGE_LEFT @"left-arrow"
#define IMAGE_FRONT_LEFT @"frontleft-arrow"
#define IMAGE_REAR_LEFT @"rearleft-arrow"
#define IMAGE_RIGHT @"right-arrow.png"
#define IMAGE_FRONT_RIGHT @"frontright-arrow"
#define IMAGE_REAR_RIGHT @"rearright-arrow"
#define IMAGE_STRAIGHT @"up-arrow"
#define IMAGE_ELEVATOR @"elevator.png"
#define IMAGE_STAIR @"walking-up-stair-sign"
#define IMAGE_ARRIVAL @"arrival"


@interface NavigationViewController ()<NSXMLParserDelegate, UITextFieldDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate>{
//  xml Parser method
    XMLDataParser *xml;

//  conpute distance method
    GeoCalculation *geoCalculation;
    
//  integer to record how many waypoints have traveld
    int walkedWaypoint;
    dispatch_semaphore_t semaphore;
    
//  count current site
    int pathValue;

//  record array size of navigation path
    int navpathCount;
    
//  siri speaker
    AVSpeechSynthesizer *pathSpeaker;
    
    BOOL resetFlag;
    
    double keyboardDuration;
    BOOL startFlag;
    
}


// start----Variables used to store routing data--------------------------------
// Dictionary for storing region data
@property (strong, nonatomic) NSMutableDictionary *regionData;

// An array of Region object storing the information of region that will be
// traveled through
@property (strong, nonatomic) NSMutableArray *regionPath;

// An array of NavigationSubgraph object representing a Navigation Graph
@property (strong, nonatomic) NSMutableArray *navigationGraph;

// An array of Vertex object representing a navigation path
@property (strong, nonatomic) NSMutableArray *navigationPath;
// A dictionary to save UUID & Name
@property (strong, nonatomic) NSMutableDictionary *UUIDtoNameDict;

// An array of Location object representing a location data
@property (strong, nonatomic) NSMutableArray *locationData;
// end----Variables used to store routing data----------------------------------


// start----objects used to provide voice and test navigation guidance----------
// Indicator for popupwindow notifying user to make a turn at each waypoint
@property (strong, nonatomic) NSString *turnNotificationForPoput;

// display for destination point
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;

// display for current location
@property (weak, nonatomic) IBOutlet UILabel *nowatLabel;

// textual navigational instruction
@property (weak, nonatomic) IBOutlet UILabel *firstMovement;
@property (weak, nonatomic) IBOutlet UILabel *howFarToMove;
@property (weak, nonatomic) IBOutlet UILabel *nextTurnMovement;
@property (weak, nonatomic) IBOutlet UILabel *currentMovement;
// graphical navigational indicator
@property (weak, nonatomic) IBOutlet UIImageView *imageTurnIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageCurrentIndicator;

// view of display the next step information
@property (weak, nonatomic) IBOutlet UIView *nextStepView;
// end----objects used to provide voice and test navigation guidance------------


// start -------------------objects of Lbeacon-------------------
// sring for storing currently received Lbeacon ID
@property (strong, nonatomic) NSString *currentLBeaconID;

// to store beacon data
@property (strong, nonatomic) CLLocationManager *beaconManager;

// to store beacon data at array
@property (strong, nonatomic) NSMutableArray<CLBeacon *> *beaconList;

// to store beacon region
@property (strong, nonatomic) NSMutableArray<CLBeaconRegion *> *beaconRegions;

// to stor beacon data and beacon identifier at dictionary
@property (strong, nonatomic) NSMutableDictionary<CLBeacon *,CLBeaconRegion *> *regionForBeacon;

// record time of timer
@property int second;
// end -------------------objects of Lbeacon-------------------


// view for display navigation progress bar
@property (weak, nonatomic) IBOutlet UIView *navGraph;



// start----variables created for demo purpose----------------------------------
@property (weak, nonatomic) IBOutlet UITextField *pointDisplay;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UITextField *testTextField;
@property (weak, nonatomic) IBOutlet UIStackView *simulationTestStackView;
// end----variables created for demo purpose------------------------------------

// new created - Paul
@property (strong, nonatomic) CBCentralManager *blueboothCentralManager;

@end

@implementation NavigationViewController{
    int stateFlag;
    BOOL speakerOfNextStep;
    BOOL currentDisplayFlag;
    NSString *currentAction;
    NavigatorFunction *navigatorFunction;
    NavigatorFunction *getPath;
}

// When view load
#pragma mark - Main Code
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // display the name of distination point
    self.destinationLabel.text = self.destinationText;
    
    // -------------------------------------------- start initialization variable --------------------------------------------
    // self.setting = [Setting new];
    walkedWaypoint = 0;
    self.turnNotificationForPoput = nil;
    pathValue = 0;
    semaphore = dispatch_semaphore_create(0);
    self.regionData = [NSMutableDictionary new];
    self.navigationGraph = [NSMutableArray new];
    self.navigationPath = [NSMutableArray new];
    self.UUIDtoNameDict = [NSMutableDictionary new];
    geoCalculation = [GeoCalculation new];
    pathSpeaker = [AVSpeechSynthesizer new];
    speakerOfNextStep = NO;
    currentDisplayFlag = NO;
    startFlag = YES;
    currentAction = FRONT;
    self.beaconList = [NSMutableArray array];
    self.beaconRegions = [NSMutableArray new];
    self.regionForBeacon = [NSMutableDictionary dictionary];
    self.locationData = [NSMutableArray new];
    resetFlag = NO;
    navigatorFunction = [NavigatorFunction new];
    getPath = [[NavigatorFunction alloc] initForNavigationPathWithPreferenceSetting:self.setting];
    // -------------------------------------------- end initialization variable ----------------------------------------------
    
    
    // ------------------------- control keyboard display and hidden -------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // ------------------------- control keyboard display and hidden -------------------------
    
    
    // control simulationtest stack view display
    [self.simulationTestStackView setHidden:![[NSUserDefaults standardUserDefaults] boolForKey:@"simulationTest"]];
    
    @autoreleasepool{
        
        pathSpeaker.delegate = self;
        self.testTextField.delegate = self;
        
        NSLog(@"self.startID is %@", self.startID);
        if ([self.starRegion isEqual:@""]){
            self.starRegion = [getPath resetNavigationPathWithFileName:FILENAME SourceID:self.startID];
            NSLog(@"self.starRegion self.starRegion is %@", self.starRegion);
        }
        [getPath readBuildingWaypointDataForBuildingName:@"buildingA" SourceRegion:self.starRegion DestinationRegion:self.destinationRegion];
        
        // start navigate
        [getPath computeNavigationPathForSourceID:self.startID DestinationID:self.DestinationID];
        self.regionData = getPath.regionData;
        self.regionPath = getPath.regionPath;
        self.navigationGraph = getPath.navigationGraph;
        self.navigationPath = getPath.navigationPath;
        self.UUIDtoNameDict = getPath.UUIDtoNameDict;
        self.locationData = getPath.locationData;
        NSLog(@"startflag:%d",startFlag);
        NSLog(@"NavPath2:%@",self.navigationPath);
        // display waypoint ID when demo
        NSString *testDisplay=[NSString new];
        for (int i = 0; i<self.navigationPath.count; i++) {
            testDisplay= [NSString stringWithFormat:@"%@%@   ",testDisplay,[[self.navigationPath objectAtIndex:i] Name]];
        }
        self.pointDisplay.text = testDisplay;
        NSLog(@"path line:%@",testDisplay);
        NSLog(@"setting:%d",self.setting.getMobilityValue);
        
        // record array size of navigation path
        navpathCount = (int)self.navigationPath.count;

        // draw navigation progress bar
        [self drawNavGraph];
        
        // navigation thread start
        // [self navThread];
        [self threadNavigator];
    }
    
}

// When view distory
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

// after view appear
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    // check if beacon ranging is available on user device.
    if ([CLLocationManager isRangingAvailable]) {
        
        // initialize CLLocationManager and make ourselves the delegate of it
        self.beaconManager = [CLLocationManager new];
        self.beaconManager.delegate = self;
        
        // request Permission
        [self startBluetoothStatusMonitoring];
        // requests permission to use location services while the app is in the foreground.
//        [self.beaconManager requestWhenInUseAuthorization];
        [self.beaconManager requestAlwaysAuthorization];
        self.beaconManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.beaconManager.distanceFilter = kCLDistanceFilterNone;
        self.beaconManager.allowsBackgroundLocationUpdates = YES;
        self.beaconManager.pausesLocationUpdatesAutomatically = NO;
        
        xml = [XMLDataParser new];
        [xml startXMLParserForUUID:@"buildingA"];
        
        NSMutableDictionary *uuidData = [xml returnUUIDData];
//        NSMutableArray<CLBeaconRegion *> *beaconRegions = [NSMutableArray new];
        
        for(id key in uuidData){
            [self.beaconRegions addObject:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[uuidData objectForKey:key]] identifier:key]];
            self.beaconRegions[self.beaconRegions.count - 1].notifyEntryStateOnDisplay = YES;
            self.beaconRegions[self.beaconRegions.count - 1].notifyOnEntry = YES;
            self.beaconRegions[self.beaconRegions.count - 1].notifyOnExit = YES;
        }
        
        [[NSNotificationCenter defaultCenter]
         addObserverForName:UIApplicationBackgroundRefreshStatusDidChangeNotification
         object: [UIApplication sharedApplication]
         queue:nil
         usingBlock:^(NSNotification* notification) {
             NSLog(@"Just changed background refresh status because of this notification:%@", notification);
             if( [self isMonitoringSupported]) {
                 [self startMonitoringAndRanging];
             }
         }];
        
        for (CLBeaconRegion *beaconRegion in self.beaconRegions) {
            NSLog(@"start monitoring and ranging ..... \n");
//            [self.beaconManager startMonitoringForRegion:beaconRegion];
            [self.beaconManager startRangingBeaconsInRegion:beaconRegion];
            [self.beaconManager startUpdatingLocation];
        }
        
    }
    else{
        // if ranging was unavailable, to let the user know and we go back.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unsupported" message:@"Beacon ranging unavailable on this device." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// When view disapper do
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    for (CLBeaconRegion *region in self.beaconRegions) {
        [self.beaconManager stopMonitoringForRegion:region];
        [self.beaconManager stopRangingBeaconsInRegion:region];
        [self.beaconManager stopUpdatingLocation];
    }
}


#pragma mark - Test Operational
// When nextStep button click
- (IBAction)nextStepBtnAction:(id)sender {
    
    self.currentLBeaconID = self.testTextField.text;
    [getPath setCurrentLBeaconID:self.currentLBeaconID];
    [self drawNowPointGraph:pathValue];
    if (startFlag) {
        startFlag = NO;
    }
    pathValue++;
    dispatch_semaphore_signal(semaphore);
}

// when click return button on keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// view moves up when keyboard display
- (void)keyboardWillShow:(NSNotification *)notification{
    
    CGSize keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardFrame.height;
    keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:keyboardDuration animations:^{
        self.view.frame = CGRectMake(0, -keyboardHeight, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

// View  moves down when keyboard hidden
- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:keyboardDuration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

#pragma mark - LBeacon, CLLocationManager Delegate
/* Tells the delegate that one or more beacons are in range. */
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    // to test beacon
    NSMutableString *outputText = [NSMutableString stringWithFormat:@"Ranged beacons count:%i\n",(int)beacons.count];
    for (CLBeacon *beacon in beacons) {
        NSLog(@"\n\naccuracy is %f\n", beacon.accuracy);  // show accuracy
        [outputText appendString:beacon.proximityUUID.UUIDString];
        [outputText appendString:[beacon.description substringFromIndex:[beacon.description rangeOfString:@"major:"].location]];
        [outputText appendString:@"\n\n"];
    }
    
    if (beacons.count != 0) {
        NSLog(@"%@",outputText);
        NSLog(@"startflag2:%d",startFlag);
    }
    
    // to find same data in data of scanning
    for (CLBeacon *beacon in beacons) {
        NSUInteger index = [self.beaconList indexOfObjectPassingTest:^BOOL(CLBeacon * _Nonnull obj, NSUInteger idx,BOOL * _Nonnull stop){
            BOOL match = [obj.proximityUUID.UUIDString isEqualToString:beacon.proximityUUID.UUIDString] &&
                            (obj.major.integerValue == beacon.major.integerValue) &&
                            (obj.minor.integerValue == beacon.minor.integerValue);
            
            if (match) {
                *stop = YES;
            }
            return match;
        }];
        
        // when have same data to update array and disctionary
        if (index != NSNotFound) {
            self.regionForBeacon[self.beaconList[index]] = nil;
            self.beaconList[index] = beacon;
            self.regionForBeacon[beacon] = region;
        }
        // when have no same data to add in array and dictionary
        else {
            [self.beaconList addObject:beacon];
            self.regionForBeacon[beacon] = region;
        }
        NSInteger distance = [navigatorFunction RSSIJudgment:beacon];
        
        // when user at the 1st waypoint
        // NSLog(@"\nStartCurrentLBeaconID is %@\nbeacon.proximityUUID.UUIDString is %@", self.currentLBeaconID, beacon.proximityUUID.UUIDString);
        BOOL isBeaconNameSame = [[self.UUIDtoNameDict objectForKey:[self.currentLBeaconID uppercaseStringWithLocale:[NSLocale currentLocale]]] isEqualToString:
                                 [self.UUIDtoNameDict objectForKey:[beacon.proximityUUID.UUIDString uppercaseStringWithLocale:[NSLocale currentLocale]]]];
        
        if (startFlag) {
            if (!isBeaconNameSame && (distance == 1 || distance == 0)) {
                NSLog(@"t14");
                currentDisplayFlag = YES;
                self.currentLBeaconID = beacon.proximityUUID.UUIDString;
                [getPath setCurrentLBeaconID:self.currentLBeaconID];
                [self drawNowPointGraph:pathValue];
                pathValue++;
                dispatch_semaphore_signal(semaphore);  // lanuch function(threadNavigator) and compare the UUID whether correct
            }
        }
        else {
            if (distance == 1 && !isBeaconNameSame) {
                NSLog(@"t10");
                self.currentLBeaconID = beacon.proximityUUID.UUIDString;
                [getPath setCurrentLBeaconID:self.currentLBeaconID];
                currentDisplayFlag = NO;
                self.firstMovement.hidden = NO;
                self.howFarToMove.hidden = NO;
                [self drawNowPointGraph:pathValue];
                pathValue++;
                dispatch_semaphore_signal(semaphore);  // lanuch function(threadNavigator) and compare the UUID whether correct
            }
            else if (distance == 0) {
                if (!currentDisplayFlag && isBeaconNameSame) {
                    NSLog(@"t10:%i",(int)distance);
                    currentDisplayFlag = YES;
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    
                    if (self.navigationPath.count == 0) {
                        [self showPopupWindow:ARRIVED_NOTIFIER];
                    }
                    else {
                        self.imageCurrentIndicator.image = [UIImage imageNamed:IMAGE_STRAIGHT];
                        self.currentMovement.text = [NSString stringWithFormat:@"%@%@",self.firstMovement.text,self.howFarToMove.text];
                    }
                    self.firstMovement.hidden = YES;
                    self.howFarToMove.hidden = YES;
                }
            }
        }
    }
    
}

/* Tells the delegate that the user enter  specified region. */
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"did enter the region ...\n");
    if([region isKindOfClass:[CLBeaconRegion class]]){
        [self.beaconManager startRangingBeaconsInRegion:(CLBeaconRegion *) region];
    }
}

/* Tells the delegate that the user left the specified region. */
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"did exit the region ...\n");
    if([region isKindOfClass:[CLBeaconRegion class]]){
//        [self.beaconManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

/* Tells the delegate about the state of the specified region. (required) */
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    //check if the region is beacon region
    if([region isKindOfClass:[CLBeaconRegion class]]) {
        if(state == CLRegionStateInside) {
            [self.beaconManager startRangingBeaconsInRegion:(CLBeaconRegion *) region];
            [self locationManager:self.beaconManager didEnterRegion:region];
            
        }
        else if(state == CLRegionStateOutside) {
            //stop ranging beacons
            [self.beaconManager stopRangingBeaconsInRegion:(CLBeaconRegion *) region];
            [self locationManager:self.beaconManager didExitRegion:region];
        }
    }
}

/* Tells the delegate that a new region is being monitored. */
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self.beaconManager requestStateForRegion:region];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // Delegate of the location manager, when you have an error
    NSLog(@"didFailWithError: %@", error);    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];  // manager == self.beaconManagerman
    }
    
    if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"The user denied authorization");
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"The user accepted authorization");
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        // user allowed
        if ([self isMonitoringSupported]) {
            [self startMonitoringAndRanging];
        }
        else {
            NSLog(@"Monitoring is not supported ......\n");
        }
    }
}

#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch ([central state]) {
        case CBManagerStateUnsupported:
            NSLog(@"This app is not supported.\n");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"This app is not authorised to use Bluetooth low energy.\n");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"Bluetooth is currently powered off.\n");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"Bluetooth is currently powered on and available to use.\n");
            // user allowed
            if ([self isMonitoringSupported]) {
                [self startMonitoringAndRanging];
            }
            else {
                NSLog(@"Monitoring is not supported ......\n");
            }
            
            break;
        default:
            NSLog(@"Break!!!!\n");
            break;
    }
    
}

- (void)startBluetoothStatusMonitoring {
    self.blueboothCentralManager = [[CBCentralManager alloc]
                                 initWithDelegate:self
                                 queue:dispatch_get_main_queue()
                                 options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}

// Checks if iBeacon monitoring is supported
-(BOOL)isMonitoringSupported {
    NSMutableString*message =  [[NSMutableString alloc]initWithCapacity:0];
    BOOL enabled = NO;
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        enabled = YES;
    }
    else {
        enabled = NO;
        NSLog(@"Region Monitoring is not available on this device");
    }
    
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        enabled = YES && enabled;
    }
    else {
        enabled = NO;
        NSLog(@"Applications must be explicitly authorized to use location services by the user and location services must themselves currently be enabled for the system.");
    }
    
    //background refreshing
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        enabled = YES && enabled;
        
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
        enabled = NO;
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        [message appendFormat:@"%@ /n %@ ",message, @"unavailable on this system due to device configuration; the user cannot enable the feature."];
        enabled = NO;
    }
    
    return enabled;
}

// Start monitoring and ranging regions
-(void)startMonitoringAndRanging {
    for (CLBeaconRegion *region in self.beaconRegions) {
        NSLog(@"start monitoring and ranging ..... \n");
        [self.beaconManager startMonitoringForRegion:region];
        [self.beaconManager startRangingBeaconsInRegion:region];
        [self.beaconManager startUpdatingLocation];  // catch lat & lng
        [self.beaconManager performSelector:@selector(requestStateForRegion:) withObject:region afterDelay:1];
    }
}

// Set text and image instruction
#pragma mark - InstructionHandler
-(void)instructionHandler:(NSString *)message{
    
    // distance to the next waypoint
    int distance = 0;
    UIImage *image = [UIImage new];
    
    // if there are two or more waypoints to go
    if (self.navigationPath.count >= 2) {
        distance = [geoCalculation getDistance:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1]];
    }
    
    // recive a turn direction message from threadForHandleLbeaconID
    NSString *s = message;
    
    // determine the instruction message
    if ([s isEqualToString:LEFT]) {
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = LEFT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);
        self.nextTurnMovement.text = THEN_TURN_LEFT;
        image = [UIImage imageNamed:IMAGE_LEFT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:FRONT_LEFT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = FRONT_LEFT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);
        self.nextTurnMovement.text = THEN_TURN_FRONT_LEFT;
        image = [UIImage imageNamed:IMAGE_FRONT_LEFT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:REAR_LEFT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = REAR_LEFT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        self.nextTurnMovement.text = THEN_TURN_REAR_LEFT;
        image = [UIImage imageNamed:IMAGE_REAR_LEFT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:RIGHT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        self.turnNotificationForPoput = RIGHT;
        self.nextTurnMovement.text = THEN_TURN_RIGHT;
        image = [UIImage imageNamed:IMAGE_RIGHT];
        NSLog(@"turnpop:%@",self.turnNotificationForPoput);
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:FRONT_RIGHT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = FRONT_RIGHT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        self.nextTurnMovement.text = THEN_TURN_FRONT_RIGHT;
        image = [UIImage imageNamed:IMAGE_FRONT_RIGHT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:REAR_RIGHT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = REAR_RIGHT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);
        self.nextTurnMovement.text = THEN_TURN_REAR_RIGHT;
        image = [UIImage imageNamed:IMAGE_REAR_RIGHT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:FRONT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        self.turnNotificationForPoput = FRONT;
        self.nextTurnMovement.text = THEN_GO_STRAIGHT;
        image = [UIImage imageNamed:IMAGE_STRAIGHT];
        self.imageTurnIndicator.image = image;
        NSLog(@"turnpop:%@",self.turnNotificationForPoput);
        
    }
    
    else if ([s isEqualToString:STAIR]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = STAIR;
        self.firstMovement.text = WALK_UP_STAIR;
        self.howFarToMove.text = @"";
        self.nextTurnMovement.text = @"";
        image = [UIImage imageNamed:IMAGE_STAIR];
        self.imageTurnIndicator.image = image;
        walkedWaypoint = 0;
        self.startID = [[self.navigationPath objectAtIndex:1] ID];
    }
    
    else if ([s isEqualToString:STAIRING]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = STAIR;
        self.firstMovement.text = WALK_UP_STAIR;
        self.howFarToMove.text = @"";
        self.nextTurnMovement.text = @"";
        image = [UIImage imageNamed:IMAGE_STAIR];
        self.imageTurnIndicator.image = image;
        walkedWaypoint = 0;
        self.startID = [[self.navigationPath objectAtIndex:1] ID];
    }
    
    else if ([s isEqualToString:ELEVATOR]) {
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = ELEVATOR;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);
        self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;
        image = [UIImage imageNamed:IMAGE_ELEVATOR];
        self.imageTurnIndicator.image = image;
        walkedWaypoint = 0;
        self.startID = [[self.navigationPath objectAtIndex:1] ID];
    }
    
    else if ([s isEqualToString:ELEVATORING]) {
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        NSString *npRegion = [[self.navigationPath objectAtIndex:2] Region];
        self.turnNotificationForPoput = ELEVATORING;
        self.firstMovement.text = TAKE_ELEVATOR_TO(npRegion);
        self.howFarToMove.text = @"";
        self.nextTurnMovement.text = OUT_OF_ELEVATOR;
        image = [UIImage imageNamed:IMAGE_ELEVATOR];
        self.imageTurnIndicator.image = image;
        walkedWaypoint = 0;
        self.startID = [[self.navigationPath objectAtIndex:1] ID];
    }
    
    else if ([s isEqualToString:ARRIVED]) {
        walkedWaypoint = 0;
    }
    
    else if ([s isEqualToString:WRONG]) {
        self.turnNotificationForPoput = nil;
        NSLog(@"currentLBeaconID is %@\n", [self.currentLBeaconID uppercaseStringWithLocale:[NSLocale currentLocale]]);
        // self.startID = self.currentLBeaconID;
        self.startID = [self.currentLBeaconID uppercaseStringWithLocale:[NSLocale currentLocale]];
        self.starRegion = [getPath resetNavigationPathWithFileName:FILENAME SourceID:self.startID];
        resetFlag = YES;
        dispatch_semaphore_signal(self->semaphore);
        [self showPopupWindow:WRONGWAY_NOTIFIER];
        walkedWaypoint = 0;
    }
    
    if (self.navigationPath.count == 2) {
        self.nextTurnMovement.text = YOU_HAVE_ARRIVE;
        self.imageTurnIndicator.image = [UIImage imageNamed:IMAGE_ARRIVAL];
    }
    
    // determine the first object in navigation path
    if (startFlag) {
        startFlag = NO;
        self.imageCurrentIndicator.image = [UIImage imageNamed:IMAGE_STRAIGHT];
        self.currentMovement.text = [NSString stringWithFormat:@"%@%@",self.firstMovement.text,self.howFarToMove.text];
        NSLog(@"%@",self.currentMovement.text);
        self.firstMovement.hidden = YES;
        self.howFarToMove.hidden = YES;
    }
    
    else{
        // display current step
        [self currentStepInfor];
    }
    
    
    
    //After the navigational instruction for current waypoint is properly given,
    //the waypoint is removed from the top of the navigationPath
    [self.navigationPath removeObjectAtIndex:0];
    NSLog(@"nextmove:%@",s);
    NSLog(@"剩下%d",(int)self.navigationPath.count);
}

// Display Current step information
-(void)currentStepInfor{
    UIImage *currentImage = [UIImage new];
    NSLog(@"currentMove:%@",currentAction);
    // when user at the final waypoint
    if (self.navigationPath.count == 1) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        self.currentMovement.text = YOU_WILL_ARRIVE;
        currentImage = [UIImage imageNamed:IMAGE_ARRIVAL];
        self.imageCurrentIndicator.image = currentImage;
        self.nextStepView.hidden = YES;
    }
    else if (!currentDisplayFlag) {
        // display current step
        if ([currentAction isEqualToString:FRONT]) {
            self.currentMovement.text = PLEASE_GO_STRAIGHT;
            currentImage = [UIImage imageNamed:IMAGE_STRAIGHT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:LEFT]){
            self.currentMovement.text = PLEASE_TURN_LEFT;
            currentImage = [UIImage imageNamed:IMAGE_LEFT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:FRONT_LEFT]){
            self.currentMovement.text = PLEASE_TURN_FRONT_LEFT;
            currentImage = [UIImage imageNamed:IMAGE_FRONT_LEFT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:REAR_LEFT]){
            self.currentMovement.text = PLEASE_TURN_REAR_LEFT;
            currentImage = [UIImage imageNamed:IMAGE_REAR_LEFT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:RIGHT]){
            self.currentMovement.text = PLEASE_TURN_RIGHT;
            currentImage = [UIImage imageNamed:IMAGE_RIGHT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:FRONT_RIGHT]){
            self.currentMovement.text = PLEASE_TURN_FRONT_RIGHT;
            currentImage = [UIImage imageNamed:IMAGE_FRONT_RIGHT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:REAR_RIGHT]){
            self.currentMovement.text = PLEASE_TURN_REAR_RIGHT;
            currentImage = [UIImage imageNamed:IMAGE_REAR_RIGHT];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:STAIR]){
            self.currentMovement.text = PLEASE_WALK_UP_STAIR;
            currentImage = [UIImage imageNamed:IMAGE_STAIR];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:ELEVATOR]){
            self.currentMovement.text = PLEASE_TAKE_ELEVATOR;
            currentImage = [UIImage imageNamed:IMAGE_ELEVATOR];
            self.imageCurrentIndicator.image = currentImage;
        }
        else if ([currentAction isEqualToString:ELEVATORING]){
            self.currentMovement.text = OUT_OF_ELEVATOR;
            currentImage = [UIImage imageNamed:IMAGE_ELEVATOR];
            self.imageCurrentIndicator.image = currentImage;
        }
    }
    
}

// Setting current location on UI
-(void)currentPointHandler:(NSString *)message{
    NSString *currentLocation = message;
    NSLog(@"nowat:%@",currentLocation);
    self.nowatLabel.text = currentLocation;
}

// Set number of waypoint traveled in this navigation tour
-(void)walkedPointHandler:(NSString *)message{
    int numberOfWaypointTraveled = (int)[message integerValue];
    
    //If it is the first waypoint of travel of a region, meaning that
    //heading correction is needed
    if (numberOfWaypointTraveled == 1 && self.navigationPath.count>=1) {
        self.turnNotificationForPoput = nil;
        
        //Start CompassActivity
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CompassViewController *compassPage = [storyBoard instantiateViewControllerWithIdentifier:@"CompassPage"];
        compassPage.passedDegree = [geoCalculation getBearingFromCoordinate:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1]];
        //[self.navigationController pushViewController:compassPage animated:YES];
        
    }
}

#pragma mark - navigation Thread
// Create a thread  to handle the currently recevied Lbeacon ID
-(void)threadNavigator{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.navigationPath.count != 0) {
            // the thread waits for beacon manager to notify it when a new
            // Lbeacon ID is received
            dispatch_semaphore_wait(self->semaphore, DISPATCH_TIME_FOREVER);
            self->speakerOfNextStep = NO;
            NSLog(@"current:%@vs%@",self.currentLBeaconID,[[self.navigationPath objectAtIndex:0] ID]);
            
            // when resetFlag is "YES",the thread ends
            if (self->resetFlag) {
                break;
            }
            
            // compare the received ID whether match in the path
            [self->getPath navigation];
            
            self->walkedWaypoint = [self->getPath walkWaypoint];
            if (![[self->getPath messageFromWalkedPointHandle] isEqualToString:@""] && ![[self->getPath messageFromCurrentPositionHandler] isEqualToString:@""]) {
                // send the newly updated message to three thread method
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self walkedPointHandler:[self->getPath messageFromWalkedPointHandle]];
                });
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self instructionHandler:[self->getPath messageFromInstructionHandler]];
                });
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self currentPointHandler:[self->getPath messageFromCurrentPositionHandler]];
                });
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self instructionHandler:[self->getPath messageFromInstructionHandler]];
                });
            }
            self.navigationPath = [self->getPath navigationPath];
        }
    });
}


#pragma mark - Notifiction Alert
// Popup window for turn direction notification
- (void) showPopupWindow :(const int) flag{
    UIAlertController *popupWindow = [UIAlertController new];
    UIAlertAction *okAlertButton = [UIAlertAction new];

    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

    stateFlag = flag;
    
    // set text of alert and alert button
    if (flag == ARRIVED_NOTIFIER) {
        popupWindow = [UIAlertController alertControllerWithTitle:YOU_HAVE_ARRIVE message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        // View back to home page when button on alert click
        okAlertButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    else if (flag == WRONGWAY_NOTIFIER){
        popupWindow = [UIAlertController alertControllerWithTitle:GET_LOST message:@"" preferredStyle:UIAlertControllerStyleAlert];
        // View back to home page when button on alert click
        okAlertButton = [UIAlertAction actionWithTitle:@"重新導航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            NSLog(@"reSTART=>Start:%@,Destination:%@",self.startID,self.DestinationID);
            [self viewDidLoad];
        }];
    }
    else if (flag == MAKETURN_NOTIFIER){
        
        if ([self.turnNotificationForPoput isEqualToString:RIGHT]) {
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TURN_RIGHT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:LEFT]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TURN_LEFT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:FRONT_RIGHT]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TURN_FRONT_RIGHT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:REAR_RIGHT]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TURN_REAR_RIGHT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:FRONT_LEFT]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TURN_FRONT_LEFT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:REAR_LEFT]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TURN_REAR_LEFT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:FRONT]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_GO_STRAIGHT message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:ELEVATOR]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_TAKE_ELEVATOR message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:ELEVATORING]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_OUT_OF_ELEVATOR message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:STAIR]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_WALK_UP_STAIR message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:STAIRING]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_WALK_UP_STAIR message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:ARRIVED]){
            popupWindow = [UIAlertController alertControllerWithTitle:YOU_HAVE_ARRIVE message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        currentAction = self.turnNotificationForPoput;
       
        // the speech manager start when button on alert click
        okAlertButton = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (self->speakerOfNextStep == NO) {
                NSString *navtxt = [NSString stringWithFormat:@"%@%@%@",self.firstMovement.text,self.howFarToMove.text,self.nextTurnMovement.text];
                [self navTxtSpeaker:navtxt];
            }
            self->speakerOfNextStep = YES;
        }];
        
    }
    
    // display alert and the speech manager start
    [self presentViewController:popupWindow animated:YES completion:^(void){
        NSString *navtxt = popupWindow.title;
        [self navTxtSpeaker:navtxt];
    }];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertviewButton"] == YES) {
        // the alert button add alert
        [popupWindow addAction:okAlertButton];
    }
    else if([[NSUserDefaults standardUserDefaults] boolForKey:@"alertviewButton"] == NO){
        // call automatic clase alertview
        [self performSelector:@selector(dismissAlert:) withObject:popupWindow afterDelay:ALERTVIEW_DISMISS_TIME];
    }
}

// automatic close alertview method
-(void) dismissAlert:(UIAlertController*) alertView {
    
    if (stateFlag == ARRIVED_NOTIFIER) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (stateFlag == WRONGWAY_NOTIFIER) {
        self.startID = self.currentLBeaconID;
        self.starRegion = [getPath resetNavigationPathWithFileName:FILENAME SourceID:self.startID];
        resetFlag = YES;
        dispatch_semaphore_signal(semaphore);
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        NSLog(@"reSTART=>Start:%@,Destination:%@",self.startID,self.DestinationID);
        [self viewDidLoad];
        
    }
    else if (stateFlag == MAKETURN_NOTIFIER) {
        
        if (speakerOfNextStep == NO) {
            NSString *navtxt = [NSString stringWithFormat:@"%@%@%@",self.firstMovement.text,self.howFarToMove.text,self.nextTurnMovement.text];
            [self navTxtSpeaker:navtxt];
        }
        speakerOfNextStep = YES;
        [alertView dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - DrawProgressBar
// draw the initialization progress bar
-(void) drawNavGraph{
    @autoreleasepool{
        
//      define the object of drawlayer, drawpath and progress text
        CAShapeLayer *graphLineLayer = [CAShapeLayer layer];
        UIBezierPath *navLine = [UIBezierPath bezierPath];
        CATextLayer *progressText = [CATextLayer new];
        
//      set start point and end point for drawing the bar
        CGPoint startp = CGPointMake(self.view.bounds.size.width*0.05, self.navGraph.frame.size.height/2);
        CGPoint endp = CGPointMake(self.view.bounds.size.width*0.95, self.navGraph.frame.size.height/2);
        NSLog(@"NavGraphHeight1:%.2f",self.navGraph.bounds.size.height/2);
        //  draw navigation progress bar line
        [navLine moveToPoint:startp];
        [navLine addLineToPoint:endp];
        graphLineLayer.lineWidth = 23;
        graphLineLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
        graphLineLayer.fillColor = nil;
        graphLineLayer.lineCap = kCALineCapRound;
        graphLineLayer.path = navLine.CGPath;
        [self.navGraph.layer addSublayer:graphLineLayer];
        
//      add progress text to progress bar
        [progressText setFrame:CGRectMake(self.view.bounds.size.width/2-40, self.navGraph.frame.size.height/2-10, 80, 20)];
        [progressText setFont:@"Helvetica-Neue"];
        [progressText setFontSize:18.0f];
        [progressText setAlignmentMode:kCAAlignmentCenter];
        [progressText setForegroundColor:[[UIColor blackColor] CGColor]];
        [progressText setString:@"0 %"];
        [self.navGraph.layer addSublayer:progressText];
        
    }

}

// draw current progress graph
- (void) drawNowPointGraph :(int) site{
    @autoreleasepool{
        
//      define the objects of drawlayer, drawpath and progress text
        CAShapeLayer *nowGraphLineLayer = [CAShapeLayer layer];
        UIBezierPath *nowLine = [UIBezierPath bezierPath];
        CAShapeLayer *graphLineLayer = [CAShapeLayer layer];
        UIBezierPath *navLine = [UIBezierPath bezierPath];
        CATextLayer *progressText = [CATextLayer new];
        
//      set start point, end point and spacing for drawing the bar
        CGPoint startp = CGPointMake(self.view.bounds.size.width*0.05, self.navGraph.frame.size.height/2);
        CGPoint endp = CGPointMake(self.view.bounds.size.width*0.95, self.navGraph.frame.size.height/2);
        double spacing = (endp.x-startp.x)/navpathCount;
        NSLog(@"NavGraphHeight2:%.2f",self.navGraph.bounds.size.height/2);
//      avoid draw over the rang of the progress bar
        if (site<navpathCount) {
            
//          draw the background of the navigation progress bar line
            [navLine moveToPoint:startp];
            [navLine addLineToPoint:endp];
            graphLineLayer.lineWidth = 23;
            graphLineLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
            graphLineLayer.fillColor = nil;
            graphLineLayer.lineCap = kCALineCapRound;
            graphLineLayer.path = navLine.CGPath;
            [self.navGraph.layer addSublayer:graphLineLayer];
            
//          draw the current length of the navigation progress bar
            [nowLine moveToPoint:CGPointMake(startp.x, startp.y)];
            [nowLine addLineToPoint:CGPointMake(startp.x+spacing*(site+1), startp.y)];
            nowGraphLineLayer.lineWidth = 20;
            nowGraphLineLayer.strokeColor = [[UIColor orangeColor] CGColor];
            nowGraphLineLayer.fillColor = nil;
            nowGraphLineLayer.lineCap = kCALineCapRound;
            nowGraphLineLayer.path = nowLine.CGPath;
            [self.navGraph.layer addSublayer:nowGraphLineLayer];
            
//          update progress text
            [progressText setFrame:CGRectMake(self.view.bounds.size.width/2-40, self.navGraph.frame.size.height/2-10, 80, 20)];
            [progressText setFont:@"Helvetica-Neue"];
            [progressText setFontSize:18.0f];
            [progressText setAlignmentMode:kCAAlignmentCenter];
            [progressText setForegroundColor:[[UIColor blackColor] CGColor]];
            [progressText setString:[NSString stringWithFormat:@"%.1f%@",(float)100/navpathCount*(site+1),@"%"]];
            [self.navGraph.layer addSublayer:progressText];
            
        }
    }
    
    
}

#pragma mark - siri Speaker
// set the setting of the speech manager
- (void) navTxtSpeaker :(NSString *)navTxt{
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:navTxt];
    utterance.rate = 0.5;
    utterance.volume = 1;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"];
    [pathSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [pathSpeaker speakUtterance:utterance];
}

@end
