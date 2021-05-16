//
//  TableOfPlayers.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 4/30/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameOverScene.h"
#import "IntroScene.h"

@interface TableOfPlayers : CCScene <UITableViewDataSource,UITableViewDelegate>{
    TableOfPlayers *layer;
    UITableView *playerTable;
    
    //file I/O
    NSMutableArray *docFiles;
}
+(CCScene *) scene;
@property (nonatomic, retain) TableOfPlayers *layer;
@end