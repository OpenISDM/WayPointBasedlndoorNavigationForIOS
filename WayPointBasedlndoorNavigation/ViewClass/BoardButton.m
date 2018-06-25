//
//  BoardButton.m
//  WayPointBasedlndoorNavigation
//
//  Created by 盧怡靜 on 2018/6/19.
//  Copyright © 2018年 Wendy. All rights reserved.
//

#import "BoardButton.h"

@implementation BoardButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    // set button board--------------------------------------------
    // set board width
    [self.layer setBorderWidth:2/UIScreen.mainScreen.nativeScale];
    // set board corner radius
    [self.layer setCornerRadius:self.frame.size.height/4];
    // set board color
    [self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    // set button content edge
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
}


@end
