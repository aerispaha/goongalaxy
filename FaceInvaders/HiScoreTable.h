//
//  HiScoreTable.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GamePlayer.h"


@interface HiScoreTable : UITableView <UITableViewDataSource,UITableViewDelegate> {
    AppDelegate *appDelegate;

    UITableView *_scoresTable;
    
    //file I/O
    NSMutableArray *docFiles;
    NSString *gameFont;
}

@property (nonatomic, retain) UITableView *scoresTable;
@end
