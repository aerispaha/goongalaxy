//
//  AchievementsTable.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/11/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "Facebook.h"

@interface AchievementsTable : UITableView <UITableViewDataSource, UITableViewDelegate, FBRequestDelegate, UIAlertViewDelegate>{
    AppDelegate *appDelegate;
    NSString *gameFont;
    
    NSMutableArray *goals;
}
@property (nonatomic, retain) UITableView *table;

@end
