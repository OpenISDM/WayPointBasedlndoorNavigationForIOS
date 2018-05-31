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
 *       This module works as follow:
 *       1. Provides a UI for navigational guidance
 *       2. Calculate a navigation path
 *       3. Background listening to Lbeacon signals
 *
 * File Name:
 *
 *      NavigationViewController.m
 *
 * Abstract:
 *
 *      The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 *
 * Authors:
 *
 *      Wendy Lu, wendylu@iis.sinica.edu.tw
 *
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
#import "RNLBeacon/RNLBeaconScanner.h"
#import "RNLBeacon/RNLBeacon.h"
#import "RNLBeacon/RNLBeacon+Distance.h"

#pragma mark - Arg,Txt and Image Define
#define NORMAL_WAYPOINT 0
#define ELEVATOR_WAYPOINT 1
#define STAIRWELL_WAYPOINT 2
#define CONNECTPOINT 3
#define ARRIVED_NOTIFIER 0
#define WRONGWAY_NOTIFIER 1
#define MAKETURN_NOTIFIER 2

#define RSSI_THRESHOLD -65

#define FRONT @"front"
#define LEFT @"left"
#define FRONT_LEFT @"frontLeft"
#define REAR_LEFT @"rearLeft"
#define RIGHT @"right"
#define FRONT_RIGHT @"frontRight"
#define REAR_RIGHT @"rearRight"
#define ELEVATOR @"elevator"
#define STAIR @"stair"
#define ARRIVED @"arrived"
#define WRONG @"wrong"

#define GO_STRAIGHT_ABOUT @"直走約"
#define THEN_GO_STRAIGHT @"然後直走"
#define THEN_TURN_LEFT @"然後向左轉"
#define THEN_TURN_RIGHT @"然後向右轉"
#define THEN_TURN_FRONT_LEFT @"然後向左前方轉"
#define THEN_TURN_FRONT_RIGHT @"然後向右前方轉"
#define THEN_TURN_REAR_LEFT @"然後向左後方轉"
#define THEN_TURN_REAR_RIGHT @"然後向右後方轉"
#define THEN_TAKE_ELEVATOR @"然後搭電梯"
#define THEN_WALK_UP_STAIR @"然後走樓梯"
#define WAIT_FOR_ELEVATOR @"電梯中請稍候"
#define WALK_UP_STAIR @"爬樓梯中"

#define YOU_HAVE_ARRIVE @"抵達目的地"
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
#define PLEASE_WALK_UP_STAIR @"請走樓梯"

#define IMAGE_LEFT @"left-arrow.png"
#define IMAGE_FRONT_LEFT @"frontleft-arrow.png"
#define IMAGE_REAR_LEFT @"rearleft-arrow.png"
#define IMAGE_RIGHT @"right-arrow.png"
#define IMAGE_FRONT_RIGHT @"frontright-arrow.png"
#define IMAGE_REAR_RIGHT @"rearright-arrow.png"
#define IMAGE_STRAIGHT @"up-arrow.png"
#define IMAGE_ELEVATOR @"elevator.png"
#define IMAGE_STAIR @"walking-up-stair-sign.png"


@interface NavigationViewController ()<NSXMLParserDelegate,UITextFieldDelegate>{
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
    
    CBCentralManager *blueboothCentralManager;
    double keyboardDuration;
}


// start----Variables used to store routing data--------------------------------------------------------
// Dictionary for storing region data
@property (strong, nonatomic) NSMutableDictionary *regionData;

// An array of Region object storing the information of region that will be traveled through
@property (strong, nonatomic) NSMutableArray *regionPath;

// An array of NavigationSubgraph object representing a Navigation Graph
@property (strong, nonatomic) NSMutableArray *navigationGraph;

// An array of Vertex object representing a navigation path
@property (strong, nonatomic) NSMutableArray *navigationPath;
// end----Variables used to store routing data----------------------------------------------------------


// start----objects used to provide voice and test navigation guidance----------------------------------
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

// graphical navigational indicator
@property (weak, nonatomic) IBOutlet UIImageView *imageTurnIndicator;
// end----objects used to provide voice and test navigation guidance------------------------------------


// start----objects of Lbeacon--------------------------------------------------------------------------
// sring for storing currently received Lbeacon ID
@property (strong, nonatomic) NSString *currentLBeaconID;

// method for ranging Lbeacon signal
@property (strong, nonatomic) RNLBeaconScanner *beaconScanner;

// record time of timer
@property int second;
// end----objects of Lbeacon----------------------------------------------------------------------------


// view for display navigation progress bar
@property (weak, nonatomic) IBOutlet UIView *navGraph;



// start----variables created for demo purpose----------------------------------------------------------
@property (weak, nonatomic) IBOutlet UITextField *pointDisplay;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UITextField *testTextField;
// end----variables created for demo purpose------------------------------------------------------------

@end

@implementation NavigationViewController

#pragma mark - Main Code
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // display the name of distination point
    self.destinationLabel.text = self.destinationText;
    
//  start initialization variable---------------------------
//    self.setting = [Setting new];
    walkedWaypoint = 0;
    self.turnNotificationForPoput = nil;
    pathValue = 0;
    semaphore = dispatch_semaphore_create(0);
    self.regionData = [NSMutableDictionary new];
    self.navigationGraph = [NSMutableArray new];
    self.navigationPath = [NSMutableArray new];
    geoCalculation = [GeoCalculation new];
    pathSpeaker = [AVSpeechSynthesizer new];
//  end initialization variable-----------------------------
    
//  control keyboard display and hidden----------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//  control keyboard display and hidden----------------------------------------------------------
    

//    self.bluetoothManger = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    @autoreleasepool{
        
        pathSpeaker.delegate = self;
        self.testTextField.delegate = self;

//      Read the region data
        [self loadWaypointData];

//      start navigat
        [self startNavigation];
        
//      display waypoint ID when demo
        NSString *testDisplay=[NSString new];
        for (int i = 0; i<self.navigationPath.count; i++) {
            testDisplay= [NSString stringWithFormat:@"%@%@   ",testDisplay,[[self.navigationPath objectAtIndex:i] Name]];
        }
        self.pointDisplay.text = testDisplay;
        NSLog(@"path line:%@",testDisplay);
        NSLog(@"setting:%d",self.setting.getMobilityValue);
        
//      record array size of navigation path
        navpathCount = (int)self.navigationPath.count;

//      draw navigation progress bar
        [self drawNavGraph];
        
//      navigation thread start
        [self navThread];
    }
    
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

#pragma mark - Test Operational
// when nextStep button click
- (IBAction)nextStepBtnAction:(id)sender {
    
    self.currentLBeaconID = self.testTextField.text;
    [self drawNowPointGraph:pathValue];
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

// view  moves down when keyboard hidden
- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:keyboardDuration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}


#pragma mark - LBeacon
- (void)onBeaconServiceConnect{
//  set time of timer
    self.second = 3;
    
//  start scanning for Lbeacon signal
    self.beaconScanner = [RNLBeaconScanner sharedBeaconScanner];
    [RNLBeacon secondsToAverage:20];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scanTimer:) userInfo:nil repeats:YES];
    NSArray *beaconsArray = self.beaconScanner.trackedBeacons;
    if (beaconsArray.count > 0) {
        for (RNLBeacon *beacon in beaconsArray) {
            [self logBeaconData:beacon];
        }
    }
}

// load beacon ID
- (void)logBeaconData :(RNLBeacon *)beacon{
    if (beacon.rssi.intValue > RSSI_THRESHOLD) {
        
//      get site from Lbeacon ID
        NSString *CConvX,*CConvY;
        CConvX = beacon.id2;
        CConvY = beacon.id3;
//      print data to check on log
        NSLog(@"beacon,Recieved ID: %@ Length:%d",[CConvX stringByAppendingString:CConvY],(int)[CConvX stringByAppendingString:CConvY].length);
        
//      update the currentLbeaconID and go to navigation thread
        if ([self.currentLBeaconID isEqualToString:[CConvX stringByAppendingString:CConvY]]) {
            self.currentLBeaconID = [CConvX stringByAppendingString:CConvY];
        }
        
        dispatch_semaphore_signal(semaphore);
    }
}

// Lbeacon scanning timer
// a scanning per two sceconds
- (void)scanTimer :(NSTimer *) timer{
    self.second--;
    if (self.second > 0) {
        [self.beaconScanner stopScanningAltbeacons];
    }
    else{
        self.beaconScanner = [RNLBeaconScanner new];
        self.second = 3;
    }
}

//set text and image instruction
#pragma mark - InstructionHandler
-(void)instructionHandler:(NSString *)message{
    
//  distance to the next waypoint
    int distance = 0;
    UIImage *image = [UIImage new];
    
    // if there are two or more waypoints to go
    if (self.navigationPath.count >= 2) {
        distance = [geoCalculation getDistance:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1]];
    }
    
    // recive a turn direction message from threadForHandleLbeaconID
    NSString *s = message;
    
    if ([s isEqualToString:LEFT]) {
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = LEFT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_TURN_LEFT;}
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
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_TURN_FRONT_LEFT;}
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
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_TURN_REAR_LEFT;}
        image = [UIImage imageNamed:IMAGE_REAR_LEFT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:RIGHT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = RIGHT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_TURN_RIGHT;}
        image = [UIImage imageNamed:IMAGE_RIGHT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:FRONT_RIGHT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = FRONT_RIGHT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_TURN_FRONT_RIGHT;}
        image = [UIImage imageNamed:IMAGE_FRONT_RIGHT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:REAR_RIGHT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = REAR_RIGHT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_TURN_REAR_RIGHT;}
        image = [UIImage imageNamed:IMAGE_REAR_RIGHT];
        self.imageTurnIndicator.image = image;
    }
    
    else if ([s isEqualToString:FRONT]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = FRONT;
        self.firstMovement.text = GO_STRAIGHT_ABOUT;
        self.howFarToMove.text = METERS(distance);;
        if ([[self.navigationPath objectAtIndex:1] NodeType] == 1) {self.nextTurnMovement.text = THEN_TAKE_ELEVATOR;}
        else if ([[self.navigationPath objectAtIndex:1] NodeType] == 2){self.nextTurnMovement.text = THEN_WALK_UP_STAIR;}
        else {self.nextTurnMovement.text = THEN_GO_STRAIGHT;}
        image = [UIImage imageNamed:IMAGE_STRAIGHT];
        self.imageTurnIndicator.image = image;
        
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
    
    else if ([s isEqualToString:ELEVATOR]){
        if (self.turnNotificationForPoput != nil) {
            [self showPopupWindow:MAKETURN_NOTIFIER];
        }
        self.turnNotificationForPoput = ELEVATOR;
        self.firstMovement.text = WAIT_FOR_ELEVATOR;
        self.howFarToMove.text = @"";
        self.nextTurnMovement.text = @"";
        image = [UIImage imageNamed:IMAGE_ELEVATOR];
        self.imageTurnIndicator.image = image;
        walkedWaypoint = 0;
        self.startID = [[self.navigationPath objectAtIndex:1] ID];
    }
    
    else if ([s isEqualToString:ARRIVED]){
        [self showPopupWindow:ARRIVED_NOTIFIER];
        walkedWaypoint = 0;
    }
    
    else if ([s isEqualToString:WRONG]){
        self.turnNotificationForPoput = nil;
        [self showPopupWindow:WRONGWAY_NOTIFIER];
        walkedWaypoint = 0;
    }
    
    //After the navigational instruction for current waypoint is properly given,
    //the waypoint is removed from the top of the navigationPath
    [self.navigationPath removeObjectAtIndex:0];
}

// Setting current location on UI
-(void)currentPointHandler:(NSString *)message{
    NSString *currentLocation = message;
//    NSLog(@"%@",currentLocation);
    self.nowatLabel.text = currentLocation;
}

//Set number of waypoint traveled in this navigation tour
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
        [self.navigationController pushViewController:compassPage animated:YES];
        
    }
}

#pragma mark - navigation Thread
// Create a thread  to handle the currently recevied Lbeacon ID
- (void) navThread{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //while the navigation path is not finished yet
        while (self.navigationPath.count != 0) {
            
//            the thread waits for beacon manager to notify it when a new Lbeacon ID is received
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
//          if the received ID matches the ID of the next waypoint in the navigation path
            if ([[[self.navigationPath objectAtIndex:0] ID] isEqualToString:self.currentLBeaconID]) {
                
//              three string store message to corresponding handlers
                NSString *messageFromInstructionHandler;
                NSString *messageFromCurrentPositionHandler;
                NSString *messageFromWalkedPointHandle;
                
//              CurrentPointionHandler get the message of currently matched waypoint name
                messageFromCurrentPositionHandler = [[self.navigationPath objectAtIndex:0] Name];
                
//              if the navigation path has more  than three waypoint to travel
                if (self.navigationPath.count >= 3) {
                    
//                  if the next two waypoints are in the same region as the  current waypoint
//                  get the turn direction  at the  next waypoint
                    if ([[[self.navigationPath objectAtIndex:0] Region] isEqualToString:[[self.navigationPath objectAtIndex:1] Region]] && [[[self.navigationPath objectAtIndex:1] Region] isEqualToString:[[self.navigationPath objectAtIndex:2] Region]]) {
                        messageFromInstructionHandler = [geoCalculation getDirectionFromBearing:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1] :[self.navigationPath objectAtIndex:2]];
                    }
                    
//                  if the next two  waypoints are not in the same region
//                  means that the next waypoint is the last waypoint of the region travel
                    else if (![[[self.navigationPath objectAtIndex:1] Region] isEqualToString:[[self.navigationPath objectAtIndex:2] Region]]){
                        messageFromInstructionHandler = FRONT;
                    }
                    
//                  if the current waypoint and the next waypoint are not in the same region
//                  transfer through elevator or stairwell
                    else if (![[[self.navigationPath objectAtIndex:0] Region] isEqualToString:[[self.navigationPath objectAtIndex:1] Region]]){
                        if ([[self.navigationPath objectAtIndex:0] NodeType] == ELEVATOR_WAYPOINT) {
                            messageFromInstructionHandler = ELEVATOR;
                        }
                        else if ([[self.navigationPath objectAtIndex:0] NodeType] == STAIRWELL_WAYPOINT){
                            messageFromInstructionHandler = STAIR;
                        }
                        else if ([[self.navigationPath objectAtIndex:0] NodeType] == CONNECTPOINT){
                            messageFromInstructionHandler = [geoCalculation getDirectionFromBearing:[self.navigationPath objectAtIndex:0] :[self.navigationPath objectAtIndex:1] :[self.navigationPath objectAtIndex:2]];
                        }
                    }
                }
//              if there are two waypoints left in the navigation path
                else if (self.navigationPath.count == 2){
                    
//                  if the current waypoint and the next waypoint are not in the same region
                    if (![[[self.navigationPath objectAtIndex:0] Region] isEqualToString:[[self.navigationPath objectAtIndex:1] Region]]) {
                        if ([[self.navigationPath objectAtIndex:0] NodeType] == ELEVATOR_WAYPOINT) {
                            messageFromInstructionHandler = ELEVATOR;
                        }
                        else if ([[self.navigationPath objectAtIndex:0] NodeType] == STAIRWELL_WAYPOINT){
                            messageFromInstructionHandler = STAIR;
                        }
                    }
//                  else go strainght to final waypoint
                    else{
                        messageFromInstructionHandler = FRONT;
                    }
                }
//              if there is only one waypoint left,the user arrived
                else if (self.navigationPath.count == 1){
                    messageFromInstructionHandler = ARRIVED;
                }
            
//              every time the received ID is matched
//              the user is considered to travel one more waypoint
                walkedWaypoint++;
                
                
//              WalkedPoint method get the message of number
//              of waypoint hsa been travel in a region
                messageFromWalkedPointHandle = [NSString stringWithFormat:@"%i",walkedWaypoint];
                
                
//              send the newly updated message to three thread method
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self walkedPointHandler:messageFromWalkedPointHandle];
                });
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self instructionHandler:messageFromInstructionHandler];
                });
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self currentPointHandler:messageFromCurrentPositionHandler];
                });
            }
//          if the received ID does not match the ID of waypoint in the navigation path
            else if (![[[self.navigationPath objectAtIndex:0] ID] isEqualToString:self.currentLBeaconID]){
                
//              send  a "wrong" message to the tread method
                NSString *messageFromInstructionHandler;
                messageFromInstructionHandler = WRONG;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self instructionHandler:messageFromInstructionHandler];
                });

            }
        }
    });
}

#pragma mark - Notifiction Alert
// popup window for turn direction notification
- (void) showPopupWindow :(const int) flag{
    UIAlertController *popupWindow = [UIAlertController new];
    UIAlertAction *okAlertButton = [UIAlertAction new];
    
//  set text of alert and alert button
    if (flag == ARRIVED_NOTIFIER) {
        popupWindow = [UIAlertController alertControllerWithTitle:YOU_HAVE_ARRIVE message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
//      View back to home page when button on alert click
        okAlertButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    else if (flag == WRONGWAY_NOTIFIER){
        popupWindow = [UIAlertController alertControllerWithTitle:GET_LOST message:@"" preferredStyle:UIAlertControllerStyleAlert];
//      View back to home page when button on alert click
        okAlertButton = [UIAlertAction actionWithTitle:@"重新導航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popToRootViewControllerAnimated:YES];
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
        else if ([self.turnNotificationForPoput isEqualToString:STAIR]){
            popupWindow = [UIAlertController alertControllerWithTitle:PLEASE_WALK_UP_STAIR message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        else if ([self.turnNotificationForPoput isEqualToString:ARRIVED]){
            popupWindow = [UIAlertController alertControllerWithTitle:YOU_HAVE_ARRIVE message:@"" preferredStyle:UIAlertControllerStyleAlert];
        }
        
//      the speech manager start when button on alert click
        okAlertButton = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *navtxt = [NSString stringWithFormat:@"%@%@%@",self.firstMovement.text,self.howFarToMove.text,self.nextTurnMovement.text];
            [self navTxtSpeaker:navtxt];
        }];
        
    }
    
//  the alert button add alert
    [popupWindow addAction:okAlertButton];

//  display alert and the speech manager start
    [self presentViewController:popupWindow animated:YES completion:nil];
    NSString *navtxt = popupWindow.message;
    [self navTxtSpeaker:navtxt];
}

#pragma mark - Get Navigation Path
// load waypoint data
- (void) loadWaypointData{
    xml = [[XMLDataParser alloc] init];
    [xml startXMLParser:@"buildingA"];
    
//  load region data from region graph
    self.regionData = [xml returnRegionData];

//  regionPath for storing Region objects represent the regions
//  that the user passes by from source to destination
    self.regionPath = [self getRegionPath:self.starRegion DestinationRegion:self.destinationRegion];
    
//  an array of string of region name in regionPath
    NSMutableArray *regionPathID = [NSMutableArray new];
    
    for (int i = 0; i < self.regionPath.count; i++) {
        [regionPathID  addObject:[[self.regionPath objectAtIndex:i] Name]];
    }
    
//  load waypoint  data from the  navigation subgraphs according to the regionPathID
    [xml startXMLParserForPoint:regionPathID];
    self.navigationGraph = [xml returnRoutingData];
    
}

// get the region path, which means the travels order of region,
// by performing shortest path algorithm on an unweighted connected graph (Region Graph)
- (NSMutableArray *)getRegionPath :(NSString*) sourceRegion DestinationRegion:(NSString*) destinationRegion{
    NQueue *queue = [NQueue new];
    NSMutableDictionary *path = [NSMutableDictionary new];
    [queue add:[self.regionData objectForKey:sourceRegion]];
    [path setObject:@"" forKey:[[self.regionData objectForKey:sourceRegion] Name]];
    [[self.regionData objectForKey:sourceRegion] Visited:YES];
    
    while (!queue.isEmpty) {
        Region *regionNode = queue.poll;
        for (int i = 0; i < regionNode.Neighbors.count; i++) {
            NSString *nameOfNeighbor = [regionNode.Neighbors objectAtIndex:i];
            if ([self.regionData objectForKey:nameOfNeighbor] != nil && ![[self.regionData objectForKey:nameOfNeighbor] Visited]) {
                [queue add:[self.regionData objectForKey:nameOfNeighbor]];
                [path setObject:regionNode forKey:[[self.regionData objectForKey:nameOfNeighbor] Name]];
                
                [[self.regionData objectForKey:nameOfNeighbor] Visited:YES];
            }
        }
    }
    NSMutableArray *shortestRegionPath = [NSMutableArray new];
   
    while (true) {
        [shortestRegionPath addObject:[self.regionData objectForKey:destinationRegion]];
        
        if (![[[self.regionData objectForKey:destinationRegion] Name] isEqualToString:sourceRegion]) {
            destinationRegion = [[path objectForKey:[[self.regionData objectForKey:destinationRegion] Name]] Name];
        }
        else {break;}
    }
    shortestRegionPath = [NSMutableArray arrayWithArray:[[shortestRegionPath reverseObjectEnumerator] allObjects]];
    return shortestRegionPath;
}


- (void)startNavigation{
    
//  get the two Vertex objects that represent starting point and destination
    Vertex *startVertex = [[[self.navigationGraph objectAtIndex:0] verticesInSubgraph] objectForKey:self.startID];
    Vertex *endVertex = [[[self.navigationGraph objectAtIndex:self.navigationGraph.count-1] verticesInSubgraph] objectForKey:self.DestinationID];
    
//  temporary variable to record connectPointID
    int connectPointID;
    
//  if navigation in the same region
    if (self.navigationGraph.count == 1) {
    
//      preform typical dijkstra's algorithm with two given Vertex objects
        self.navigationPath = [self computeDijkstraShortestPath:startVertex :endVertex];

    }
    
//  navigation between several regions
    else{
        
//      compute N-1 navigation paths for each region,
//      where N is the number of region to travel
        
        for (int i = 0; i < self.navigationGraph.count-1; i++) {
            
//          a destination vertex for each region
            Vertex *destinationOfARegion = nil;
            
//          the source vertex becomes a normal waypoint
            [[[[self.navigationGraph objectAtIndex:i] verticesInSubgraph] objectForKey:self.startID] NodeType:NORMAL_WAYPOINT];
            
//          if  the elevation of the next region to travel is same as current region
            if ([[self.regionPath objectAtIndex:i] Elevation] == [[self.regionPath objectAtIndex:i+1] Elevation]) {
              
//              compute a path to a transfer point of current region
//              return the transfer point
                destinationOfARegion = [self computePathToTraversePoint:[[[self.navigationGraph objectAtIndex:i] verticesInSubgraph] objectForKey:self.startID] SameElevator:YES NextRegion:i+1];
                
//              startID is updated with the ID of transfer node for the next computation
//              since the transfer node has the same ID in the same elevation
                self.startID = destinationOfARegion.ID;
                
            }
            
//          if the elevation of the next region to  travel is different from the current region
            else if ([[self.regionPath objectAtIndex:i] Elevation] != [[self.regionPath objectAtIndex:i+1] Elevation]){
                
//              compute a path to a transfer point (elevator or stairwell) of current region
//              return the transfer point
                destinationOfARegion = [self computePathToTraversePoint:[[[self.navigationGraph objectAtIndex:i] verticesInSubgraph] objectForKey:self.startID] SameElevator:NO NextRegion:0];
                
//              get the connectPointID of the transfer node
                connectPointID = destinationOfARegion.ConnectPointID;
                
//              find the transfer node with the sam connectPointID in the next region
//              where elevation is different from the current region
                for (id key in [[self.navigationGraph objectAtIndex:i+1] verticesInSubgraph]) {
                    
                    Vertex *v = [[[self.navigationGraph objectAtIndex:i+1] verticesInSubgraph] objectForKey:key];
                    
                    if (v.ConnectPointID == connectPointID) {
                        NSLog(@"got2-10:%@",v.ID);
                        self.startID = v.ID;
                        break;
                    }
                }
            }
            
//          add up all the navigation paths into one
            [self.navigationPath addObjectsFromArray:[self getShortestPathToDestination:destinationOfARegion]];
        }
        
//      compute navigation path in the last region
        NSMutableArray *pathInLastRegion = [self computeDijkstraShortestPath:[[[self.navigationGraph objectAtIndex:self.navigationGraph.count-1] verticesInSubgraph] objectForKey:self.startID] :endVertex];
        
//       complete the navigation path
        [self.navigationPath addObjectsFromArray:pathInLastRegion];
        
//      remove duplicated waypoints which are used ada connecting points in the same elevation
        for (int i = 1; i < self.navigationPath.count; i++) {
            
            if ([[[self.navigationPath objectAtIndex:i] ID] isEqualToString:[[self.navigationPath objectAtIndex:i-1] ID]]) {
                
                [self.navigationPath removeObjectAtIndex:i];
            }
        }
    }
    
//  record the number of the waypoint on the navigation path
    navpathCount = (int)self.navigationPath.count;
}

//compute a shortest path with given starting point  and destination
- (NSMutableArray*) computeDijkstraShortestPath :(Vertex*) source :(Vertex*) destination{
    [source MinDistance:0];
    NQueue *queue = [[NQueue alloc] init];
    [queue add:source];
    
    while (!queue.isEmpty) {
        Vertex *v = [queue poll];
//      stop searching when reach the destination node
        if ([[v ID] isEqualToString:[destination ID]]) {
            break;
        }
//      visit each edge that is adjacent to v
        for (Edge *e in v.Adjacencies) {
            Vertex *a = [e Target];
            double weight = e.Weight;
            double distanceThroughU = v.MinDistance +weight;
            if (distanceThroughU < a.MinDistance) {
                [queue remove:a];
                [a MinDistance:distanceThroughU];
                [a Previous:v];
                [queue add:a];
            }
        }
    }
    return [self getShortestPathToDestination:destination];
}

// compute a shortest path from a given starting point to a transfer node (e.g. elevator, stairwell)
- (Vertex*) computePathToTraversePoint :(Vertex*) source SameElevator:(BOOL) sameElevator NextRegion:(int) nextRegion{
    
    [source MinDistance:0];
    NQueue *queue = [NQueue new];
    [queue add:source];
    
    while (!queue.isEmpty) {
        Vertex *u = [queue poll];
        
//      visite each edge exiting u
        for (Edge *e in u.Adjacencies) {
            Vertex *v = e.Target;
            double weight = e.Weight;
            double distanceThroughU = u.MinDistance + weight;
            if (distanceThroughU < v.MinDistance) {
                [queue remove:v];
                
                [v MinDistance:distanceThroughU];
                [v Previous:u];
                [queue add:v];
            }
            
            if (sameElevator == YES && v.NodeType == CONNECTPOINT) {
                if ([[[self.navigationGraph objectAtIndex:nextRegion] verticesInSubgraph] objectForKey:v.ID] != nil) {
                    return v;
                }
            }
            
            else if(sameElevator == NO && v.NodeType == self.setting.getMobilityValue ){
                return v;
            }
        }
        
    }
    return source;
}

// get shorteset path by traversing previous waypoint back to the source
- (NSMutableArray*) getShortestPathToDestination :(Vertex*) destination{
    NSMutableArray *path = [NSMutableArray new];
    for (Vertex *vertex = destination; vertex != nil; vertex = vertex.Previous) {
        [path addObject:vertex];
    }
    
//  reverse path to get correct order
    path = [NSMutableArray arrayWithArray:[[path reverseObjectEnumerator] allObjects]];
    return path;
}


- (NSString *) returnstartText{
    return self.startText;
}
- (NSString *) returndestinationText{
    return  self.destinationText;
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
