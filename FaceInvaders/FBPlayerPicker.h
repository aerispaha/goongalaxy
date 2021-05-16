//
//  FBPlayerPicker.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/21/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "cocos2d.h"
#import "FBConnect.h"
#import "ImageProcessor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SimpleAudioEngine.h"

@interface FBPlayerPicker : UITableView<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, FBRequestDelegate>{
    
    AppDelegate *appDelegate;
    NSArray *arrayOfPlayers;
    Facebook *fb;
    BOOL selected;
    UIImageView *controlImageView;
    UIImage *normalControlImage;
    UIImage *selectedControlImage;
    UIControl *toggleControl;
    NSString *selectedName;
    NSString *selectedFacebookID;
    
    //images
    NSString *smallProfPicUrl;
    UIImage *smallImg;
    BOOL faceFound;
    
    //filtering
    UISearchBar *searchBar;
    BOOL isFiltered;
    
    //status stuff
    UIView *inPlayerArrayView;
    
    //table processing logic
    NSMutableArray *peopleToBeProcessed;
    //NSMutableArray *processedPeople;
    BOOL isProcessing;
    NSString *gameFont;
    
}
@property (nonatomic, retain) UITableView *table;
@property (strong, nonatomic) NSMutableArray *allData;
@property (strong, nonatomic) NSMutableArray *filteredData;

- (id)initWithData:(NSArray *)data;
@end
