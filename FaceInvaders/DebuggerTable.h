//
//  DebuggerTable.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 10/29/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "ImageProcessor.h"
#import "Facebook.h"


@interface DebuggerTable : UITableView <UITableViewDataSource, UITableViewDelegate, FBRequestDelegate, UIAlertViewDelegate> {
    AppDelegate *appDelegate;
    NSMutableArray *debugImgArray;
    Facebook *fb;
    int picIndexPath;
    
    float tableScale;
}

@property (nonatomic, retain) UITableView *table;
@end
