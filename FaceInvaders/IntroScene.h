//
//  IntroScene.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/10/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "cocos2d.h"
#import "RootViewController.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HelloWorldLayer.h"
#import "ImageProcessor.h"
#import "Background.h"
#import "HiScoreTable.h"
#import "AchievementsTable.h"
#import "GamePlayerDoc.h"
#import "GoonsTable.h"
#import "PlayersTable.h"
#import "FBConnect.h"
#import "FBPlayerPicker.h"
#import "DebuggerTable.h"
#import "FaceData.h"
#import "ShipScroller.h"
#import "LoadingScene.h"
#import "OptionsScene.h"


@interface IntroLayer : CCLayerColor <UITextFieldDelegate, UITableViewDelegate, FBRequestDelegate, FBSessionDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    CCLabelTTF *_label;
    AppDelegate *appDelegate;
    CGSize winSize;
    Facebook *facebook;
    UITextField *nameField;
    NSString *playerName;
    BOOL hiScoreShown;
    BOOL playerPickerShown;
    BOOL goonPickerShown;
    BOOL fbPlayerPickerShown;
    BOOL achievementsShown;
    BOOL menusAreActive;
    BOOL optionsMessShown;

    CCSprite *ship;
    HiScoreTable *hiScoreTable;
    PlayersTable *playersTable;
    GoonsTable *goonsTable;
    FBPlayerPicker *fbPlayerPicker;
    AchievementsTable *achievementsTable;
    DebuggerTable *debugTable;
    ShipScroller *shipScroller;
   
    UIViewController *cameraViewCon;

    FaceData *faceData;
    
    //BackgroundStuff
    CCSprite *background;
    CCParallaxNode *pNode;
    CCSprite *bk1;
    CCSprite *bk2;
    NSMutableArray *_backgroundItems;
    NSMutableArray *_twinkleStars;
    
    //sounds
    NSArray *clickArr;
    int clickCount;
    
    //Menu stuff
    CCMenu *mainMenu;
    CCMenu *goonifyMenu;
    CCMenu *optionsMenu;
    CCLabelTTF *optionsMessage;
    UISwitch *musicSwitch;
    UISwitch *soundFXSwitch;
    CCLabelBMFont *musicLab;
    CCLabelBMFont *FXLab;
}


+(CCScene *) scene;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) CCLabelTTF *label;
//@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@end

@interface IntroScene : CCScene {
    IntroScene *_layer;
}
@property (nonatomic, retain) IntroLayer *layer;

@end
