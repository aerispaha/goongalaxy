//
//  GoonsTable.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 1/4/13.
//  Copyright (c) 2013 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "cocos2d.h"
#import "FaceData.h"
#import "SimpleAudioEngine.h"

@interface PlayersTable : UITableView <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>{
    
    AppDelegate *appDelegate;
    NSMutableArray *arrayOfPlayers;
    
    BOOL selected;
    UIImageView *controlImageView;
    UIImage *normalControlImage;
    UIImage *selectedControlImage;
    UIControl *toggleControl;
    
    NSMutableArray *faceDataFiles;
    int numOfRows;
    
    //FaceData *fd;
    
    //filter stuff
    UISearchBar *searchBar;
    BOOL isFiltered;
    
    NSString *gameFont;
    
    int heroIndex;
}

@property (nonatomic, retain) UITableView *table;
@property (strong, nonatomic) NSMutableArray *allData;
@property (strong, nonatomic) NSMutableArray *filteredData;


@end
