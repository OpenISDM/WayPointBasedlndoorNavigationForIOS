/*
   Copyright (c) 2018 Academia Sinica, Institute of Information Science
 
   License:
 
        GPL 3.0 : The content of this file is subject to the terms and
        conditions defined in file 'COPYING.txt', which is part of this source
        code package.
 
   Project Name:
 
        WayPointBasedIndoorNavigationForIOS
 
   File Description:
 
        This is the file processing the xml data of the building file
 
   File Name:
 
        XMLDataParser.m
 
   Abstract:
 
        The WayPointBasedIndoorNavigationForIOS is smartphone UI for iOS user.
 
   Authors:
 
        Wendy Lu, wendylu@iis.sinica.edu.tw
        Paul Chang, paulchang@iis.sinica.edu.tw
 
 */

//
//  XMLDataParser.m
//  WayPointBasedlndoorNavigation
//
//  Created by Wendy on 2018/2/12.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "XMLDataParser.h"

@interface XMLDataParser (){
    NavigationSubgraph *navigationSubgraph;
    Region *rlocation;
    Vertex *vlocation;
    BOOL fileflag;
    NSString *filenameFlag;
    BOOL allDataFlag;
}
@property (strong, nonatomic) NSString *fileDirName;
@end

@implementation XMLDataParser

-(instancetype)init{
    if (self = [super init]) {
        self.regionData = [NSMutableDictionary new];
        self.routingData = [NSMutableArray new];
        navigationSubgraph = [NavigationSubgraph new];
        self.categoryList = [NSMutableArray new];
        self.categoryData = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Do XML Parser
- (void)startXMLParser: (NSString*) filename{
    
    self.localArray = [[NSMutableArray alloc] init];
    self.groupBeaconArray = [[NSMutableArray alloc] init];
    self.fileDirName = filename;
    fileflag = YES;
    
    //open indoorpoint data file & save data & close file
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml" inDirectory:filename];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    
    //test the data
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataString);
    
    //start parser
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    [xmlParser setDelegate:self];
    
    //test the parser start success
    BOOL flag = [xmlParser parse];
    if (flag){
        NSLog(@"xmlDataParser start");
    }
    else{
        NSLog(@"xmlDataParser no start");
    }
}

// for UUID
-(void)startXMLParserForUUID:(NSString *)filename{
    
    self.uuidData = [NSMutableDictionary new];
    self.fileDirName = filename;
    fileflag = NO;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"UUID" ofType:@"xml" inDirectory:filename];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    // test the data
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataString);
    
    // start parser
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:data];
    [xmlParser setDelegate:self];
    
    //test the  parser start success
    BOOL flag = [xmlParser parse];
    if (flag) {
        NSLog(@"UUID-xmlDataParser start");
    }
    else{
        NSLog(@"UUID-xmlDataParser no start");
    }
    
}

// for waypoint
-(void)startXMLParserForPoint:(nullable NSMutableArray *)filenames fileName: (nullable NSString *) filename{
    
    fileflag = NO;
    allDataFlag = NO;
    
    if (filenames.count == 0) {
        NSArray *opaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"xml" inDirectory:filename];

        for (NSString *path in opaths) {
            if ([path containsString:@"region"]) {
                filenameFlag = [[path lastPathComponent] stringByDeletingPathExtension];
                allDataFlag = YES;
                NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
                NSData *data = [file readDataToEndOfFile];
                [file closeFile];
                
                //test the data
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",dataString);
                
                //start parser
                NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
                [xmlParser setDelegate:self];
                
                //test the parser start success
                BOOL flag = [xmlParser parse];
                if (flag){
                    NSLog(@"xmlAllDataParser start");
                }
                else{
                    NSLog(@"xmlDataParser no start");
                }
            }
        }
    }
    else{
        for (NSString *s in filenames) {
            
            filenameFlag = s;
            NSString *path = [[NSBundle mainBundle] pathForResource:s ofType:@"xml" inDirectory:self.fileDirName];
            allDataFlag = NO;
            
            NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
            NSData *data = [file readDataToEndOfFile];
            [file closeFile];
            
            //test the data
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",dataString);
            
            //start parser
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
            [xmlParser setDelegate:self];
            
            //test the parser start success
            BOOL flag = [xmlParser parse];
            if (flag){
                NSLog(@"xmlDataParser start");
            }
            else{
                NSLog(@"xmlDataParser no start");
            }
            
        }
    }
    
    
}

// Ｇet the attributeDict content
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    
    // save attribute in array
    if ([elementName isEqualToString:@"region"]) {
        NSLog(@"a1");
        NSString *name = [attributeDict objectForKey:@"name"];
        NSString *neighbor1 = [attributeDict objectForKey:@"neighbor1"];
        NSString *neighbor2 = [attributeDict objectForKey:@"neighbor2"];
        NSString *neighbor3 = [attributeDict objectForKey:@"neighbor3"];
        NSString *neighbor4 = [attributeDict objectForKey:@"neighbor4"];
        int elevation = 0;
        NSMutableArray *neighbors = [NSMutableArray new];
        
        if (![neighbor1 isEqualToString:@""]) {[neighbors addObject:neighbor1];}
        if (![neighbor2 isEqualToString:@""]) {[neighbors addObject:neighbor2];}
        if (![neighbor3 isEqualToString:@""]) {[neighbors addObject:neighbor3];}
        if (![neighbor4 isEqualToString:@""]) {[neighbors addObject:neighbor4];}
        
        if (![[attributeDict objectForKey:@"elevation"] isEqualToString:@""]) {
            elevation = [[attributeDict objectForKey:@"elevation"] intValue];
        }
        rlocation = [[Region alloc] initForRegion:name Neighbors:neighbors LocationsOfRegion:nil Elevation:elevation];
        NSLog(@"a2");
    }
    else if ([elementName isEqualToString:@"location"]){
        NSString *_ID = [attributeDict objectForKey:@"id"];
        NSString *_name = [attributeDict objectForKey:@"name"];
        NSString *_region = [attributeDict objectForKey:@"region"];
        NSString *_category = [attributeDict objectForKey:@"category"];
        
        if (![self categoryExist:self.categoryList Target:_category]) {
            [self.categoryList addObject:_category];
        }
        // use uppercaseString method to convert all UUID to upper case
        vlocation = [[Vertex alloc] initForUIDisplay:[_ID uppercaseString] Name:_name Region:_region Category:_category];
        BOOL isGroupBeacon = NO;
        //check whether is group beacon
        for (Vertex *_v in self.localArray) {
            if ([vlocation.Name isEqualToString:_v.Name]) {
                [self.groupBeaconArray addObject:vlocation];  // add group beacon
                isGroupBeacon = YES;
                break;
            }
        }
        
        if (!isGroupBeacon) {
            [self.localArray addObject:vlocation];
        }
        
    }
    else if ([elementName isEqualToString:@"node"]){
        NSString *_ID = [attributeDict objectForKey:@"id"];
        NSString *_name = [attributeDict objectForKey:@"name"];
        double _lat = [[attributeDict objectForKey:@"lat"] doubleValue];
        double _lon = [[attributeDict objectForKey:@"lon"] doubleValue];
        NSString *_region = [attributeDict objectForKey:@"region"];
        NSString *_category = [attributeDict objectForKey:@"category"];
        NSString *neighbor1 = [attributeDict objectForKey:@"neighbor1"];
        NSString *neighbor2 = [attributeDict objectForKey:@"neighbor2"];
        NSString *neighbor3 = [attributeDict objectForKey:@"neighbor3"];
        NSString *neighbor4 = [attributeDict objectForKey:@"neighbor4"];
        int _nodetype = 0,_connectPointID = 0,_elevation = 0;
        NSMutableArray *_neighbors = [NSMutableArray new];
        
        if (![neighbor1 isEqualToString:@""]) {[_neighbors addObject:neighbor1];}
        if (![neighbor2 isEqualToString:@""]) {[_neighbors addObject:neighbor2];}
        if (![neighbor3 isEqualToString:@""]) {[_neighbors addObject:neighbor3];}
        if (![neighbor4 isEqualToString:@""]) {[_neighbors addObject:neighbor4];}
        
        if (![[attributeDict objectForKey:@"nodeType"] isEqualToString:@""]) {_nodetype = [[attributeDict objectForKey:@"nodeType"] intValue];}
        if (![[attributeDict objectForKey:@"connectPointID"] isEqualToString:@""]){_connectPointID = [[attributeDict objectForKey:@"connectPointID"] intValue];}
        if (![[attributeDict objectForKey:@"elevation"] isEqualToString:@""]){_elevation = [[attributeDict objectForKey:@"elevation"] intValue];}
        
        if (allDataFlag) {
            Vertex *vnode = [[Vertex alloc] initForUIDisplay:_ID Name:_name Region:_region Category:_category];
            [self.routingData addObject:vnode];
        }
        else{
            Vertex *vnode = [[Vertex alloc] initForRouteComputation:_ID Name:_name Lat:_lat Lon:_lon Neighbors:_neighbors Region:_region Category:_category NodeType:_nodetype ConnectPoint:_connectPointID];
            [navigationSubgraph.verticesInSubgraph setObject:vnode forKey:vnode.ID];
        }
        
    }
    else if ([elementName isEqualToString:@"nodeuuid"]) {
        // convert all uuid to uppercase
        NSString *_uuid = [[attributeDict objectForKey:@"UUID"] uppercaseStringWithLocale:[NSLocale currentLocale]];
        NSString *_identifier = [attributeDict objectForKey:@"Identifier"];
        
        if (![_uuid isEqualToString:@""] && ![_identifier isEqualToString:@""]) {
            [self.uuidData setObject:_uuid forKey:_identifier];
        }
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"region"]) {
        NSLog(@"a3");
        [rlocation LocationOfRegion:self.localArray];
        [self.regionData setObject:rlocation forKey:rlocation.Name];
        
    }
    else if ([elementName isEqualToString:filenameFlag] && !allDataFlag){
        NSLog(@"QWER:%@",filenameFlag);
        [navigationSubgraph addEdge];
        [self.routingData addObject:navigationSubgraph];
        NSLog(@"t6:%@ %@",filenameFlag,navigationSubgraph);
        navigationSubgraph = [NavigationSubgraph new];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    if (fileflag == YES) {
        for (int i = 0; i < self.categoryList.count; i++) {
            NSMutableArray *temp = [NSMutableArray new];
            for (Vertex *v in self.localArray) {
                if ([v.Category isEqualToString:[self.categoryList objectAtIndex:i]]) {
                    [temp addObject:v];
                }
            }
            [self.categoryData setObject:temp forKey:[self.categoryList objectAtIndex:i]];
        }
    }
}

#pragma mark - return data
//return all buildingD data
-(NSMutableDictionary *)returnRegionData{
    return self.regionData;
}

-(NSMutableArray *)returnLocalData{
    return self.localArray;
}

-(NSMutableArray *)returnGroupBeaconArray {
    return self.groupBeaconArray;
}

-(NSMutableArray *)returnRoutingData{
    return self.routingData;
}

-(NSMutableArray *)CategoryList{
    return self.categoryList;
}

-(NSMutableDictionary *)returnCategoryData{
    NSLog(@"qt:%@",self.categoryData);
    return self.categoryData;
}

-(NSMutableDictionary *)returnUUIDData{
    return self.uuidData;
}

#pragma mark - CategoryList Method

-(void) clearCategoryList{
    [self.categoryList removeAllObjects];
}

- (BOOL) categoryExist :(NSMutableArray*) arr Target:(NSString*) target{
    for (NSString *s in arr) {
        if ([s isEqualToString:target]) {
            return YES;
        }
    }
    return NO;
}

@end
