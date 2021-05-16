//
//  PlayersTable.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/22/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "cocos2d.h"
#import "FaceData.h"
#import "SimpleAudioEngine.h"



@interface GoonsTable : UITableView <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>{
    
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
}

@property (nonatomic, retain) UITableView *table;
@property (strong, nonatomic) NSMutableArray *allData;
@property (strong, nonatomic) NSMutableArray *filteredData;

@end
