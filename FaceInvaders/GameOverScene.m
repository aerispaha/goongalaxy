//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 3/6/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "GameOverScene.h"
#import "HelloWorldLayer.h"
//#import "TableOfPlayers.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "ImageProcessor.h"
#import "IntroScene.h"


#define ARC4RANDOM_MAX      0x100000000

@implementation GameOverScene
@synthesize layer = _layer;
- (id)init {
    
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}
- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}
@end

@implementation GameOverLayer
@synthesize label = _label;
@synthesize message = _message;

- (id) init{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        NSLog(@"GameOverScene loaded");
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        gameFont =  appDelegate.gameFont;//[NSString stringWithFormat:@"friendly robot"];
        
        winSize = [[CCDirector sharedDirector] winSize];
        explodePoss = [[NSMutableArray alloc] init];
        /*
        //Set text of buttons 
        CCLabelTTF *replayButtLab = [CCLabelTTF labelWithString:@"Replay!" fontName:gameFont fontSize:30];
        CCLabelTTF *menuButtLab =   [CCLabelTTF labelWithString:@"Menu" fontName:gameFont fontSize:30];
        CCLabelTTF *screensButtLab =   [CCLabelTTF labelWithString:@"Screens" fontName:gameFont fontSize:30];
        
        //Make buttons
        CCMenuItem *replayButt = [CCMenuItemLabel itemWithLabel:replayButtLab target:self selector:@selector(returnToGame)];
        CCMenuItem *menuButt = [CCMenuItemLabel itemWithLabel:menuButtLab target:self selector:@selector(returnToMenu)];
        CCMenuItem *screensButt = [CCMenuItemLabel itemWithLabel:screensButtLab target:self selector:@selector(showScreenShits)];
        
        //Position buttons
        replayButt.position = ccp(0, winSize.height*0.67);
        menuButt.position = ccp(0, winSize.height*0.33);
        
        //Make menu and fill with buttons
        CCMenu *menu = [CCMenu menuWithItems:replayButt, menuButt, nil];
        menu.position = CGPointMake(winSize.width*0.83, 0);
        
        //NSLog(@"going to load screen shot table");
        //screenShotTable = [[ScreenShotTable alloc] initWithMessage:appDelegate.gameOverMessage];
        //[[[CCDirector sharedDirector] openGLView] addSubview:screenShotTable.table];
        
        [self addChild:menu];
        */
        
        [self addMainMenu];
        [self addGameResults];
        [self addSpecialResults];
        screenShitsShown = NO;
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"GoonGalaxy01.mp3" loop:YES];
        
        }	
    return self;
}
- (void)addSpecialResults{
    if ([appDelegate.currentAchievements count] > 0) {
        NSLog(@"special achievements message stuff \ncount: %d", [appDelegate.currentAchievements count]);
    }else{
        NSLog(@"NO special achievements message stuff \ncount: %d", [appDelegate.currentAchievements count]);
    }
}
- (void)addGameResults{
    //Make main menu buttons
    //Set text of buttons
    
    int currentScore    = [[appDelegate.gameStatsDic valueForKey:@"currentScore"] intValue];
    int totalKills      = [[appDelegate.gameStatsDic valueForKey:@"totalKills"] intValue];
    float gameAccuracy  = [[appDelegate.gameStatsDic valueForKey:@"accuracy"] floatValue];
    int coinsCollected  = [[appDelegate.gameStatsDic valueForKey:@"coinsCollected"] floatValue];
    int planetsVisited  = [[appDelegate.gameStatsDic valueForKey:@"planetsVisited"] intValue];
    //NSMutableArray *planetaryKillCounts  = [appDelegate.gameStatsDic objectForKey:@"planetsVisited"];
    //NSMutableArray *planetaryGoonCounts  = [appDelegate.gameStatsDic objectForKey:@"planetaryGoonCounts"];
    //int psVstdWOWrnch   = [[appDelegate.gameStatsDic valueForKey:@"planetsVisitedWithoutWrench"] intValue];
    
    NSString *scoreSt       = [NSString stringWithFormat:@"Score: %d", currentScore];
    NSString *killsSt       = [NSString stringWithFormat:@"Killz: %d", totalKills];
    NSString *accuracySt    = [NSString stringWithFormat:@"Accuracy: %.f", gameAccuracy];
    NSString *coinsSt       = [NSString stringWithFormat:@"Space Coinz: %d", coinsCollected];
    NSString *planetsVSt    = [NSString stringWithFormat:@"Planetz: %d", planetsVisited];

    NSString *fntFile = @"purpleBauh93.fnt";
    //Make buttons
    CCLabelBMFont *scoreStLab = [CCLabelBMFont labelWithString:scoreSt       fntFile:fntFile];
    CCLabelBMFont *killsStlab = [CCLabelBMFont labelWithString:killsSt       fntFile:fntFile];
    CCLabelBMFont *accuracyStLab = [CCLabelBMFont labelWithString:accuracySt    fntFile:fntFile];
    CCLabelBMFont *coinsStLab = [CCLabelBMFont labelWithString:coinsSt       fntFile:fntFile];
    CCLabelBMFont *planetsVStLab = [CCLabelBMFont labelWithString:planetsVSt    fntFile:fntFile];
    
    NSArray *array = [[NSArray alloc] initWithObjects:scoreStLab, killsStlab, accuracyStLab, coinsStLab, planetsVStLab, nil];
    
    CCMenuItem *score =     [CCMenuItemLabel itemWithLabel:scoreStLab];
    CCMenuItem *kills =     [CCMenuItemLabel itemWithLabel:killsStlab];
    CCMenuItem *accuracy =  [CCMenuItemLabel itemWithLabel:accuracyStLab];
    CCMenuItem *coins =     [CCMenuItemLabel itemWithLabel:coinsStLab];
    CCMenuItem *planets =   [CCMenuItemLabel itemWithLabel:planetsVStLab];
    
    //Make menu and fill with buttons
    //statsMenu = [[CCMenu alloc] init];
    statsMenu = [CCMenu menuWithItems:score, kills, accuracy, coins, planets, nil];
    
    float delayForAction = 0.5;
    for (CCMenuItem *label in statsMenu.children) {
        //scale up and right justify with anchor point
        CCLabelBMFont *item = (CCLabelBMFont *)label;
        item.scale = 1.167;
        //item.scale = 0.2;
        item.anchorPoint = ccp(0, 0.5);
        item.visible = NO;
        id delay = [CCDelayTime actionWithDuration:delayForAction];
        //id scale = [CCScaleTo actionWithDuration:0.25 scale:1.167];
        id explode = [CCCallFuncN actionWithTarget:self selector:@selector(makeExplosionAtPos:)];
        
        [self runAction:[CCSequence actions:delay, explode, nil]];
        //[self giveFunMotionToSprite:item];
        delayForAction = delayForAction + 0.5;
    }
    
    for (CCLabelBMFont *lab in array) {
        //scale up and right justify with anchor point
        for (CCSprite *letter in lab.children) {
            [self giveFunMotionToSprite:letter];
        }
    }
    [array release]; array = nil;
    
    [statsMenu alignItemsVerticallyWithPadding:10];
    statsMenu.position = ccp(winSize.width*0.01, winSize.height/2);
    
    [self addChild:statsMenu];
    
    for (CCMenuItem *item in statsMenu.children) {
        CGPoint pos = ccpAdd(item.position, statsMenu.position);
        pos = ccp(pos.x + item.boundingBox.size.width/2, pos.y);
        [explodePoss addObject:[NSValue valueWithCGPoint:pos]];
    }
}
- (void)addMainMenu{
    //Make main menu buttons
    //Set text of buttons
    
    NSString *fntFile = @"purpleBauh93.fnt";
    
    CCLabelTTF *replayButtLab =     [CCLabelBMFont labelWithString:@"Replay!"   fntFile:fntFile];
    CCLabelTTF *menuButtLab =       [CCLabelBMFont labelWithString:@"Menu"      fntFile:fntFile];
    CCLabelTTF *screensButtLab =    [CCLabelBMFont labelWithString:@"Screens"   fntFile:fntFile];
    
    NSArray *array = [[NSArray alloc] initWithObjects:replayButtLab, menuButtLab, screensButtLab, nil];
    
    //Make buttons
    CCMenuItem *replayButt =    [CCMenuItemLabel itemWithLabel:replayButtLab target:self selector:@selector(returnToGame)];
    CCMenuItem *menuButt =      [CCMenuItemLabel itemWithLabel:menuButtLab target:self selector:@selector(returnToMenu)];
    CCMenuItem *screensButt =   [CCMenuItemLabel itemWithLabel:screensButtLab target:self selector:@selector(showScreenShits)];
    
    //Make menu and fill with buttons
    CCMenu *menu = [CCMenu menuWithItems:replayButt, /*playersButt,*/ menuButt, /*fbButt, */screensButt, nil];
    
    for (CCMenuItem *label in menu.children) {
        CCLabelBMFont *item = (CCLabelBMFont *)label;
        //scale up and right justify with anchor point
        item.scale = 1.167;
        item.anchorPoint = ccp(1, 0.5);
        
        //[self giveFunMotionToSprite:item];
    }
    
    for (CCLabelBMFont *lab in array) {
        //scale up and right justify with anchor point
        for (CCSprite *letter in lab.children) {
            [self giveFunMotionToSprite:letter];
        }
    }
    [array release]; array = nil;
    
    [menu alignItemsVerticallyWithPadding:15];
    menu.position = ccp(winSize.width*0.99, winSize.height/2);
    
    [self addChild:menu];
}
- (void)giveFunMotionToSprite:(id)sender{
    float duration = (((double)arc4random() / ARC4RANDOM_MAX)*1 + 0.75);
    int y = (arc4random() % 5) + 2;
    
    id scaleUpAction =      [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0,  y)] rate:2.0];
    id scaleDownAction =    [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0, -y)] rate:2.0];
    CCSequence *scaleSeq =  [CCSequence actions:scaleUpAction, scaleDownAction, nil];
    
    [sender runAction:[CCRepeatForever actionWithAction:scaleSeq]];
}
- (void)makeExplosionAtPos:(CGPoint )exPos{
    
    CCParticleExplosion *explosionParEmit = [[[CCParticleExplosion alloc] initWithTotalParticles:40] autorelease];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"plasma.png"];
    [explosionParEmit setTexture:[frame texture] withRect:[frame rect]];
    NSValue *pos = [explodePoss objectAtIndex:explodeNum];
    
    exPos = [pos CGPointValue];
    explosionParEmit.position = exPos;
    //explosionParEmit.totalParticles = 50;
    explosionParEmit.autoRemoveOnFinish = YES;
    explosionParEmit.speed = 80;//150;
    explosionParEmit.speedVar = 80;
    explosionParEmit.life = 0.3;
    explosionParEmit.lifeVar = 0.75;
    explosionParEmit.startColor = [Background randomBrightColor];
    explosionParEmit.startColorVar = [Background randomBrightColor];
    explosionParEmit.endColor = [Background randomBrightColor];
    explosionParEmit.endColorVar = [Background randomBrightColor];
    
    [self addChild:explosionParEmit];
    
    CCMenuItem *item =  [statsMenu.children objectAtIndex:explodeNum];
    item.visible = YES;
    
    
    explodeNum++;
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.mp3"];
    NSLog(@"make explosion at point: (%.f, %.f)",exPos.x, exPos.y);
    
}
/*
- (id)initWithMessage:(NSString *)message
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
      
        //Set text of buttons
        CCLabelTTF *replayButtLab = [CCLabelTTF labelWithString:@"Replay!" fontName:gameFont fontSize:30];
        CCLabelTTF *menuButtLab =   [CCLabelTTF labelWithString:@"Menu" fontName:gameFont fontSize:30];
        
        //Make buttons
        CCMenuItem *replayButt = [CCMenuItemLabel itemWithLabel:replayButtLab target:self selector:@selector(returnToGame)];
        CCMenuItem *menuButt = [CCMenuItemLabel itemWithLabel:menuButtLab target:self selector:@selector(returnToMenu)];
        
        //Position buttons
        replayButt.position = ccp(0, winSize.height*0.67);
        menuButt.position = ccp(0, winSize.height*0.33);
        
        //Make menu and fill with buttons
        CCMenu *starMenu = [CCMenu menuWithItems:replayButt, menuButt, nil];
        starMenu.position = CGPointMake(winSize.width*0.83, 0);
        
        
        screenShotTable = [[ScreenShotTable alloc] initWithMessage:message];
        [[[CCDirector sharedDirector] openGLView] addSubview:screenShotTable.table];
        
        //update achievements array
        //appDelegate.achievementsArray = [NSMutableArray arrayWithArray:[Achievments loadDataFromDisk]];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"GoonGalaxy01.mp3" loop:YES];
        
        [self addChild:starMenu];
        
    }
    return self;
}
*/
- (void)returnToGame{
    NSLog(@"return to game called");
    if (screenShitsShown) {
        [screenShotTable.table removeFromSuperview];
        //[screenShotTable.table release];
        screenShotTable.table = nil;
    }
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    //[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitRows transitionWithDuration:0.5 scene:[LoadingScene scene]]];
    [self buttonClick];
}
- (void)returnToMenu{
    NSLog(@"Return to Menu called");
    [screenShotTable.table removeFromSuperview];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitRows transitionWithDuration:0.5 scene:[IntroLayer scene]]];
    [self buttonClick];
}
- (void)showScreenShits{
    NSLog(@"going to load screen shot table");
    if (!screenShitsShown) {
        screenShotTable = [[ScreenShotTable alloc] initWithMessage:appDelegate.gameOverMessage];
        [[[CCDirector sharedDirector] openGLView] addSubview:screenShotTable.table];
        screenShitsShown = YES;
    }else{
        [screenShotTable.table removeFromSuperview];
        //[screenShotTable.table release];
        screenShitsShown = NO;
    }
}
- (void)buttonClick{
    [[SimpleAudioEngine sharedEngine] playEffect:@"generalClick.mp3"];
}
- (void)dealloc {
    [_label release];
    _label = nil;
     [super dealloc];
}

- (void)postToFacebook{
    
    UIImage *img = [appDelegate.picturesFromGamePlay objectAtIndex:3];
    
    NSData *imageData = UIImagePNGRepresentation(img);//UIImageJPEGRepresentation(img, 0.75);
    
    Facebook *facebook = appDelegate.facebook;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[facebook accessToken], @"access_token",nil];
    //[params setObject:@"Caption to go with image" forKey:@"name"];
    [params setObject:[NSString stringWithFormat:@"testerino"] forKey:@"message"];
    [params setObject:imageData forKey:@"source"];   // myImage is the UIImage to upload
    [facebook requestWithGraphPath:@"me/photos"
                         andParams: params
                     andHttpMethod: @"POST"
                       andDelegate:(id)self];
    
}
- (void)requestLoading:(FBRequest *)request{
    NSLog(@"FB requestLoading");
    //NSLog(@"request: %@",request);
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"FB didReceiveResponse");
}
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    NSLog(@"FB didLoadRawResponse");
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"FB didLoad");
    NSLog(@"result: %@",result);
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request failed with error");
    NSLog(@"%@",[error localizedDescription]);
}
@end