//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 3/6/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "cocos2d.h"
#import "RootViewController.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ScreenShotTable.h"
#import "LoadingScene.h"
#import <MessageUI/MFMailComposeViewController.h>


@interface GameOverLayer : CCLayerColor <UINavigationControllerDelegate, UIImagePickerControllerDelegate, FBRequestDelegate, MFMailComposeViewControllerDelegate> {
    
    CCLabelTTF *_label;
    NSString *_message;
    UIImagePickerController *camera;
    AppDelegate *appDelegate;
    
    UIButton *startButt;
    UIButton *cameraButt;
    UIButton *tablePlayersButt;
    
    ScreenShotTable *screenShotTable;
    NSString *gameFont;
    CGSize winSize;
    BOOL screenShitsShown;
    NSMutableArray *explodePoss;
    int explodeNum;
    CCMenu *statsMenu;
    
}
//-(id)initWithMessage:(NSString *)message;
@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) NSString *message;
@end

@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end
