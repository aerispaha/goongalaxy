//
//  AppDelegate.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 5/31/12.
//  Copyright EychmoTech 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePlayerDoc.h"
#import "FBConnect.h"
#import "Achievments.h"





@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate>{
	UIWindow			*window;
	//RootViewController	*viewController;
    Facebook *facebook;
    //Facebook *fbFriendHandler;

}

@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) RootViewController *viewController;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIImage *face;
@property (nonatomic, retain) NSMutableArray *monsterArray;
//@property (nonatomic, retain) NSMutableArray *activeFaceArray;
@property (nonatomic, retain) NSMutableArray *faceDataArray;
@property (nonatomic, retain) NSMutableArray *activeFaceDataArray;
@property (nonatomic, retain) NSMutableArray *faceBookFriendsData;
@property (nonatomic, retain) NSMutableArray *achievementsArray;
@property (nonatomic, retain) NSMutableArray *appendageArray;
@property (nonatomic, retain) NSMutableArray *planetArray;
@property (nonatomic, retain) NSMutableArray *debrisImgArray;
@property (nonatomic, retain) UIImage *bossImg;
@property (nonatomic, retain) NSString *gamePlayer;
@property (nonatomic, retain) NSString *activePlayersIndexString;
@property (nonatomic, retain) NSString *gameFont;
@property (nonatomic, retain) NSMutableArray *gamePlayerDataArray;
@property (nonatomic, retain) NSMutableArray *gamePlayerDocArray;
@property (nonatomic, retain) NSMutableArray *gameNameArray;
@property (nonatomic, retain) NSMutableArray *picturesFromGamePlay;
@property (nonatomic, retain) NSMutableArray *debuggerImages;
@property (nonatomic, retain) GamePlayerDoc *playerD;
@property (nonatomic) int heroIndex;
@property (nonatomic, retain) NSString *gameOverMessage;
@property (nonatomic, retain) NSMutableDictionary *gameStatsDic;
@property (nonatomic, retain) NSMutableArray *currentAchievements;
@property (nonatomic) BOOL musicOn;
@property (nonatomic) BOOL FXOn;






@end
