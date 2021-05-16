//
//  HiScores.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/26/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GamePlayer.h"
#import "AppDelegate.h"

@interface HiScores : CCScene <UITableViewDataSource,UITableViewDelegate>{
    AppDelegate *appDelegate;
    HiScores *layer;
    UITableView *_scoresTable;
    
    //file I/O
    NSMutableArray *docFiles;
    
}
+(CCScene *) scene;
@property (nonatomic, retain) HiScores *layer;
@property (nonatomic, retain) UITableView *scoresTable;
@end