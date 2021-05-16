//
//  IntroScene.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/10/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "IntroScene.h"


#define ARC4RANDOM_MAX      0x100000000

@implementation IntroScene
@synthesize layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [IntroLayer node];
        [self addChild:layer];
    }
    return self;
}

- (void)dealloc {
    [layer release];
    layer = nil;
    [super dealloc];
}

@end

@implementation IntroLayer

+(CCScene *) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
    NSLog(@"scene returned");
	return scene;

}

@synthesize label = _label;
@synthesize navController;

- (id) init{
    if( (self=[super initWithColor:ccc4(150,88,88,0)] )) {
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        winSize = [[CCDirector sharedDirector] winSize];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        CCSpriteBatchNode *mostSS =    [CCSpriteBatchNode batchNodeWithFile:@"THE Sheet dithered.png"];
        [self addChild:mostSS];
        
        //"cache" monster body images (from sprite sheet)
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"THE Sheet dithered.plist"];
        
        NSString *gameFont =  appDelegate.gameFont;
        
        self.label = [CCLabelTTF labelWithString:@"Goon Galaxy" fontName:gameFont fontSize:40];
        _label.color = ccc3(255,255,0);
        _label.position = ccp(winSize.height*0.05 + _label.contentSize.width/2, winSize.height*0.9);
        [self addChild:_label];
        [self giveFunMotionToSprite:_label];
        
        
        //set up menus
        [self addChild:[self goonifyMenu]]; goonifyMenu.visible = NO;
        [self addChild:[self mainMenu]];
        
        
        
        //Current user name field stuff
        NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentUser"];
        if (currentName == nil) {
            currentName = [NSString stringWithFormat:@"Player1"];
        }
        
        //player name field stuff
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, 250, 30)]; //RETINA ISSUE
        [nameField setDelegate:self];
        [nameField setText:currentName];
        [nameField setFont:[UIFont fontWithName:gameFont size:25]];
        [nameField setTextAlignment:NSTextAlignmentCenter];
        [nameField setBackgroundColor:[UIColor clearColor]];
        [nameField setTextColor: [UIColor colorWithRed:255 green:255 blue:255 alpha:1.0]];
        [nameField setReturnKeyType:UIReturnKeyDone];
        
        CGPoint pos = ccp(winSize.width*.5, winSize.height*.25);
        nameField.center = ccp(pos.x, pos.y + winSize.height*0.25); //UIKit coordinates!
        CGAffineTransform transform = CGAffineTransformMakeRotation(3.14/2);
        nameField.transform = transform;
        [[[CCDirector sharedDirector] openGLView] addSubview:nameField];
        
        //logic
        hiScoreShown = NO;
        playerPickerShown = NO;
        fbPlayerPickerShown = NO;
        goonPickerShown = NO;
        menusAreActive = YES;
        
        //FACEBOOK STuff
        //facebook = [[Facebook alloc] init];
        //facebook = appDelegate.facebook;
        
        //check if we have FB friends data
        [self facebookStuff];
        
        //[Alien addRandomBeastToLayer:self];
        [self setUpBackground];
        [self addShip];
        
        
        clickArr = [[NSArray alloc] initWithObjects:
                             @"toneClick1.mp3",
                             @"toneClick2.mp3",
                             @"toneClick3.mp3",
                             @"toneClick4.mp3", nil];
        clickCount = 0;
        
        //shipScroller = [[ShipScroller alloc] initWithFrame:CGRectMake(0, 0, winSize.width*.3, winSize.height*.6)];
        //[[[CCDirector sharedDirector] openGLView] addSubview:shipScroller.scroller];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"GoonGalaxy01.mp3" loop:YES];
        
    }	
    return self;
}

- (CCMenu *)mainMenu{
    //Make main menu buttons
    NSString *fntFile = @"purpleBauh93.fnt";
    
    CCLabelBMFont *startLab =      [CCLabelBMFont labelWithString:@"Begin"         fntFile:fntFile];
    CCLabelBMFont *goonifyLab =    [CCLabelBMFont labelWithString:@"Goonify"       fntFile:fntFile];
    CCLabelBMFont *hiScoresLab =   [CCLabelBMFont labelWithString:@"HiScores"      fntFile:fntFile];
    CCLabelBMFont *missions =      [CCLabelBMFont labelWithString:@"Missions"      fntFile:fntFile];
    CCLabelBMFont *optionsLab =    [CCLabelBMFont labelWithString:@"Options"       fntFile:fntFile];
    
    NSArray *array = [[NSArray alloc] initWithObjects:startLab, goonifyLab, hiScoresLab, missions, optionsLab, nil];
    
    CCMenuItem *startButt =     [CCMenuItemLabel itemWithLabel:startLab     target:self selector:@selector(startButtonTapped:)];
    CCMenuItem *goonifyButt =   [CCMenuItemLabel itemWithLabel:goonifyLab   target:self selector:@selector(showGoonifyMenu)];
    CCMenuItem *hiScoresButt =  [CCMenuItemLabel itemWithLabel:hiScoresLab  target:self selector:@selector(hiScoresButtTapped:)];
    CCMenuItem *missionsButt =  [CCMenuItemLabel itemWithLabel:missions     target:self selector:@selector(achievementsButtTapped:)];
    CCMenuItem *optionsButt =   [CCMenuItemLabel itemWithLabel:optionsLab   target:self selector:@selector(optionsButtonTapped:)];
    
    //Make menu and fill with buttons
    mainMenu = [CCMenu menuWithItems:startButt, /*playersButt,*/ goonifyButt, /*fbButt, */hiScoresButt, missionsButt, optionsButt, nil];

    for (CCMenuItem *item in mainMenu.children) {
        //scale up and right justify with anchor point
        item.scale = 1.167;
        item.anchorPoint = ccp(1, 0.5);
        //[self giveFunMotionToSprite:item];
        
        NSLog(@"item count: %d", [item.children count]);
    }
    
    for (CCLabelBMFont *lab in array) {
        //scale up and right justify with anchor point
        for (CCSprite *letter in lab.children) {
            [self giveFunMotionToSprite:letter];
        }
    }
    [array release]; array = nil;
    NSLog(@"start Lab count: %d", [startLab.children count]);
    
    [mainMenu alignItemsVerticallyWithPadding:15];
    mainMenu.position = ccp(winSize.width*0.99, winSize.height/2);

    return mainMenu;
}
- (CCMenu *)goonifyMenu{
    //Make main menu buttons
    NSString *fntFile = @"purpleBauh93.fnt";
    
    CCLabelTTF *backLab =       [CCLabelBMFont labelWithString:@"Back"          fntFile:fntFile];
    CCLabelTTF *selectLab =     [CCLabelBMFont labelWithString:@"Select Goons"  fntFile:fntFile];
    CCLabelTTF *playerLab =     [CCLabelBMFont labelWithString:@"Select Player"  fntFile:fntFile];
    CCLabelTTF *fbGoonLab =     [CCLabelBMFont labelWithString:@"Facebook"      fntFile:fntFile];
    CCLabelTTF *camGoon =       [CCLabelBMFont labelWithString:@"Camera"        fntFile:fntFile];
    
    NSArray *array = [[NSArray alloc] initWithObjects:backLab, selectLab, playerLab, fbGoonLab, camGoon, nil];
    
    CCMenuItem *backButt =      [CCMenuItemLabel itemWithLabel:backLab      target:self selector:@selector(showMainMenu)];
    CCMenuItem *selectButt =    [CCMenuItemLabel itemWithLabel:selectLab   target:self selector:@selector(goonPickerButtTapped:)];
    CCMenuItem *playerButt =    [CCMenuItemLabel itemWithLabel:playerLab   target:self selector:@selector(playerPickerButtTapped:)];
    CCMenuItem *camButt =       [CCMenuItemLabel itemWithLabel:camGoon      target:self selector:@selector(cameraButtTapped:)];
    CCMenuItem *fbButt =        [CCMenuItemLabel itemWithLabel:fbGoonLab    target:self selector:@selector(fbFriendPickerTapped:)];
    
    //Make menu and fill with buttons
    goonifyMenu = [CCMenu menuWithItems:backButt, selectButt, playerButt, camButt, fbButt, nil];
    
    for (CCMenuItem *label in goonifyMenu.children) {
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
    
    [goonifyMenu alignItemsVerticallyWithPadding:20];
    goonifyMenu.position = ccp(winSize.width*0.99, winSize.height/2);
    
    return goonifyMenu;
}
- (CCMenu *)optionsMenu{
    //Make main menu buttons
    NSString *mus;
    NSString *fx;
    if (appDelegate.musicOn) {
        mus = @"Music On";
    }else{
        mus = @"Music Off";
    }
    if (appDelegate.FXOn) {
        fx = @"Sounds On";
    }else{
        fx = @"Sounds Off";
    }
    
    NSString *fntFile = @"purpleBauh93.fnt";
    
    CCLabelBMFont *backLab =    [CCLabelBMFont labelWithString:@"Back"          fntFile:fntFile];
    musicLab =                  [CCLabelBMFont labelWithString:mus              fntFile:fntFile];
    FXLab =                     [CCLabelBMFont labelWithString:fx               fntFile:fntFile];
    CCLabelTTF *eraseLab =      [CCLabelBMFont labelWithString:@"Erase Data"    fntFile:fntFile];
    
    NSArray *array = [[NSArray alloc] initWithObjects:backLab, musicLab, FXLab, eraseLab, nil];
    
    CCMenuItem *backButt =      [CCMenuItemLabel itemWithLabel:backLab      target:self selector:@selector(showMainMenu)];
    CCMenuItem *musicButt =     [CCMenuItemLabel itemWithLabel:musicLab     target:self selector:@selector(musicOnOrOff)];
    CCMenuItem *FXButt =        [CCMenuItemLabel itemWithLabel:FXLab        target:self selector:@selector(FXOnOrOff)];
    CCMenuItem *eraseButt =     [CCMenuItemLabel itemWithLabel:eraseLab     target:self selector:@selector(eraseDataButtonTapped:)];
    
    //Make menu and fill with buttons
    optionsMenu = [CCMenu menuWithItems:backButt, musicButt, FXButt, eraseButt, nil];
    
    for (CCMenuItem *label in optionsMenu.children) {
        CCLabelBMFont *item = (CCLabelBMFont *)label;
        //scale up and right justify with anchor point
        item.scale = 1.167;
        item.anchorPoint = ccp(1, 0.5);
        
        [self giveFunMotionToSprite:item];
    }
    
    for (CCLabelBMFont *lab in array) {
        //scale up and right justify with anchor point
        for (CCSprite *letter in lab.children) {
            [self giveFunMotionToSprite:letter];
        }
    }
    [array release]; array = nil;
    
    [optionsMenu alignItemsVerticallyWithPadding:20];
    optionsMenu.position = ccp(winSize.width*0.99, winSize.height/2);
    
    return optionsMenu;
}

- (void)setUpBackground{
    
    pNode = [CCParallaxNode node];
    [self addChild:pNode z:-3];
    CGPoint spaceSpeed = ccp(0.01, 0.01);

    bk1 = [CCSprite spriteWithFile:@"Space2.png"];
    bk2 = [CCSprite spriteWithFile:@"Space2.png"];
    
    [pNode addChild:bk1 z:0 parallaxRatio:spaceSpeed positionOffset:ccp(0,winSize.height/2)];
    [pNode addChild:bk2 z:0 parallaxRatio:spaceSpeed positionOffset:ccp(bk1.contentSize.width,winSize.height/2)];
    
    [self schedule:@selector(update:)];
    
    _backgroundItems = [[NSMutableArray alloc] init];
    _twinkleStars = [[NSMutableArray alloc] init];
    [self schedule:@selector(addBackgroundSprites) interval:6];
    [self schedule:@selector(addTwinkleStars) interval:2];
    
    /*
    CCParticleRain *dots = [[[CCParticleRain alloc] init] autorelease];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blueDot.png"];
    [dots setTexture:[frame texture] withRect:[frame rect]];
    dots.gravity = ccp(0, winSize.height/2);
    dots.position = ccp(winSize.width, winSize.height/2);
    dots.rotation = 270;
    dots.startColorVar = ccc4FFromccc3B(ccc3(0, 0, 0));
    dots.endColorVar = ccc4FFromccc3B(ccc3(0, 0, 0));
    dots.startSize = frame.rect.size.width;
    dots.startSizeVar = 0;
    dots.endSize = frame.rect.size.width;
    [self addChild:dots z:pNode.zOrder];
    */
}
- (void)addBackgroundSprites{
    
    //CGPoint floatMtSpd = ccp(0.006, 1);
    int numOfBackGrounds = 8;
    int bk = arc4random() % numOfBackGrounds;
    CCSprite *backgroundItem;
    if (bk == 0) {
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"BigCrescent.png"];
    }else if (bk == 1){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"BigSwirlPlanet.png"];
    }else if (bk == 2){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SwirlPlanet.png"];
    }else if (bk == 3){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallSwirlPlanet.png"];
    }else if (bk == 4){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"RedPlanet.png"];
    }else if (bk == 5){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallRedPlanet.png"];
    }else if (bk == 6){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"Crescent.png"];
    }else if (bk == 7){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallCrescent.png"];
    }
    
    backgroundItem.tag = 5; //background images stuff
   
    
    [_backgroundItems addObject:backgroundItem];
    
    // Determine where to spawn the target along the Y axis
    int minY = -backgroundItem.contentSize.height/2;
    int maxY = winSize.height + backgroundItem.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    backgroundItem.position = ccp(winSize.width + (backgroundItem.contentSize.width/2), actualY);
    [backgroundItem setColor:[Background randomDullColor3B]];
    [self addChild:backgroundItem z:pNode.zOrder+1];
    backgroundItem.tag = 5;
    
    // Determine speed of the target
    int actualDuration = (arc4random() % 13) + 10;
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-backgroundItem.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [backgroundItem runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
}
- (void)addTwinkleStars{
    //CGPoint floatMtSpd = ccp(0.006, 1);
    int numOfBackGrounds = 5;
    int star = arc4random() % numOfBackGrounds;
    CCSprite *backgroundItem;
    if       (star == 0){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"Yellow4Star.png"];
    }else if (star == 1){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallYellow4Star.png"];
    }else if (star == 2){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallYellow4Star.png"];
    }else if (star == 3){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallYellow4Star.png"];
    }else if (star == 4){
        backgroundItem = [CCSprite spriteWithSpriteFrameName:@"SmallRedStar.png"];
    }
    
    backgroundItem.tag = 6; //background images stuff
    backgroundItem.rotation = 45;
    
    [_twinkleStars addObject:backgroundItem];
    
    // Determine where to spawn the target along the Y axis
    int minY = -backgroundItem.contentSize.height/2;
    int maxY = winSize.height + backgroundItem.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    backgroundItem.position = ccp(winSize.width + (backgroundItem.contentSize.width/2), actualY);
    
    [self addChild:backgroundItem z:pNode.zOrder+1];
    backgroundItem.tag = 5;
    
    // Determine speed of the target
    int actualDuration = (arc4random() % 5) + 25;
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-backgroundItem.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [backgroundItem runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    [self makeStrobe:backgroundItem WithDuration:2];
}
- (void)makeStrobe:(CCSprite *)sprite WithDuration:(float)duration{
    id dim =        [CCFadeTo actionWithDuration:duration opacity:50];
    id brighten =   [CCFadeTo actionWithDuration:duration opacity:255];
    id seq = [CCSequence actions:dim, brighten, nil];
    [sprite runAction:[CCRepeatForever actionWithAction:seq]];
}
- (void)spriteMoveFinished:(id)sender {
    CPSprite *sprite = (CPSprite *)sender;
    
    [self removeChild:sprite cleanup:YES];
    
    if (sprite.tag == 5) {//background images stuff
        [_backgroundItems removeObject:sprite];
    }if (sprite.tag == 6) {//background images stuff
        [_twinkleStars removeObject:sprite];
    }
}
- (void)addShip{
    ship = [Player largePlayer];
    ship.position = ccp(nameField.center.y, winSize.height*0.4);
    ship.rotation = 5;
    float wobbleSpeed = 0.2;

    id rotL = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:wobbleSpeed angle:-10] rate:2.0];
    
    id rotR = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:wobbleSpeed angle:10] rate:2];
    id rotSeq = [CCSequence actions:rotL, rotR, nil];
    [ship runAction:[CCRepeatForever actionWithAction:rotSeq]];
    id moveUp = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:wobbleSpeed position:ccp(0, 10)] rate:2];
    id moveDwn = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:wobbleSpeed position:ccp(0, -10)] rate:2];
    id delay = [CCDelayTime actionWithDuration:wobbleSpeed];
    id moveSeq = [CCSequence actions:moveUp, delay, moveDwn, delay, nil];
     
    [ship runAction:[CCRepeatForever actionWithAction:moveSeq]];
    
    [self addChild:ship];
}
- (void)giveFunMotionToSprite:(id)sender{    
    float duration = (((double)arc4random() / ARC4RANDOM_MAX)*1 + 0.75);
    int y = (arc4random() % 5) + 2;
    
    id scaleUpAction =      [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0,  y)] rate:2.0];
    id scaleDownAction =    [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0, -y)] rate:2.0];
    CCSequence *scaleSeq =  [CCSequence actions:scaleUpAction, scaleDownAction, nil];
    
    [sender runAction:[CCRepeatForever actionWithAction:scaleSeq]];
}
- (void)update:(ccTime)dt{
    
    //PARALLAX STUFF
    
    CGPoint pVel = ccp(-1000, 0);
    pNode.position =   ccpAdd(pNode.position, ccpMult(pVel, dt));
    NSArray *bkgrnds = [NSArray arrayWithObjects:bk1, bk2, nil];
    for (CCSprite *bk in bkgrnds) {
        if ([pNode convertToWorldSpace:bk.position].x < -bk.contentSize.width) {
            [pNode incrementOffset:ccp(2*bk.contentSize.width,0) forChild:bk];
        }
    }
}

#pragma mark BUTTON RECEIVERS
- (void)showMainMenu{
    [self buttClickSounds];
    mainMenu.visible = YES;
    goonifyMenu.visible = NO;
    optionsMenu.visible = NO;
    optionsMessage.visible = NO;


    [self removeSubViewsAndThings];
    [self returnSubsAndThings];
}
- (void)showGoonifyMenu{
    [self buttClickSounds];
    mainMenu.visible = NO;
    goonifyMenu.visible = YES;
    
    [self removeSubViewsAndThings];
    [self returnSubsAndThings];
}
- (void)startButtonTapped:(id)sender {
    [self buttClickSounds];
    [self removeSubViewsAndThings];
    [nameField removeFromSuperview];
    
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    //[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitRows transitionWithDuration:0.5 scene:[LoadingScene scene]]];
}
- (void)optionsButtonTapped:(id)sender {
    [self buttClickSounds];
    [self removeSubViewsAndThings];
    mainMenu.visible = NO;

    optionsMessage = [CCLabelTTF labelWithString:@"Code and Concept by\nAdam Erispaha, @eychmotech \n\nGraphic Design by\nStephanie Kakaletris\n stephaniekakaletris.com\n\nAudio Engineer: Anthony Cistulli\nCistulliSound, @mickeytrousers\n\nMany Thanks To:\nRayWenderlich.com\ncocos2d.org\nCopyright 2013 Adam Erispaha"
                                              dimensions:CGSizeMake(winSize.width/2, winSize.height*0.95)
                                               alignment:NSTextAlignmentCenter
                                           lineBreakMode:NSLineBreakByWordWrapping
                                                fontName:appDelegate.gameFont fontSize:15];
    
    optionsMessage.position = ccp(winSize.width/4, winSize.height/2);
    [self addChild:optionsMessage];
    [self addChild:[self optionsMenu]];
    optionsMessShown = YES;
    
}
- (void)eraseDataButtonTapped:(id)sender {
    [self buttClickSounds];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Clear Game Data"
                                                     message:@"Are you sure you want to erase your high scores and achievements data?"
                                                    delegate:self
                                           cancelButtonTitle:@"Nope"
                                           otherButtonTitles:@"Yes", nil] autorelease];
    [alert show];
    
}
- (void)cameraButtTapped:(id)sender {
    [self buttClickSounds];
    [self removeSubViewsAndThings];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && menusAreActive) {
        NSLog(@"Camera is available");
        
        //Add viewcontroller that can take modal views
        cameraViewCon = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        [[[CCDirector sharedDirector] openGLView] addSubview:cameraViewCon.view];
        
        //add modal imagePicker
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [cameraViewCon presentViewController:picker animated:YES completion:nil];
        menusAreActive = NO;
        [picker release];
        
    }else{
        NSLog(@"Camera is NOT available");
    }
}
- (void)hiScoresButtTapped:(id)sender{
    [self buttClickSounds];
    if (!hiScoreShown && menusAreActive) {
        [self removeSubViewsAndThings];
        hiScoreTable = [[HiScoreTable alloc] init];
        [[[CCDirector sharedDirector] openGLView] addSubview:hiScoreTable.scoresTable];
        hiScoreShown = YES;
    }else {
        [hiScoreTable.scoresTable removeFromSuperview];
        //[hiScoreTable.scoresTable release];
        hiScoreTable.scoresTable = nil;
        hiScoreShown = NO;

        [self returnSubsAndThings];
    }
    
}
- (void)fbFriendPickerTapped:(id)sender{
    [self buttClickSounds];
    if (!fbPlayerPickerShown && menusAreActive) {
        [self removeSubViewsAndThings];
        fbPlayerPicker = [[FBPlayerPicker alloc] initWithData:appDelegate.faceBookFriendsData];
        [[[CCDirector sharedDirector] openGLView] addSubview:fbPlayerPicker.table];
        fbPlayerPickerShown = YES;
        
    }else {
        [fbPlayerPicker.table removeFromSuperview];
        //[fbPlayerPicker.table release];
        fbPlayerPicker.table = nil;
        fbPlayerPickerShown = NO;
        [self returnSubsAndThings];
    }
    
}
- (void)goonPickerButtTapped:(id)sender{
    [self buttClickSounds];
    if (!goonPickerShown && menusAreActive) {
        [self removeSubViewsAndThings];
        goonsTable = [[GoonsTable alloc] init];
        [[[CCDirector sharedDirector] openGLView] addSubview:goonsTable.table];
        goonPickerShown = YES;
        
        
    }else {
        [goonsTable.table removeFromSuperview];
        //[playersTable.table release];
        goonsTable.table = nil;
        goonPickerShown = NO;
        [self returnSubsAndThings];
    }
    
}
- (void)playerPickerButtTapped:(id)sender{
    [self buttClickSounds];
    if (!playerPickerShown && menusAreActive) {
        [self removeSubViewsAndThings];
        playersTable = [[PlayersTable alloc] init];
        [[[CCDirector sharedDirector] openGLView] addSubview:playersTable.table];
        playerPickerShown = YES;
        
        
    }else {
        [playersTable.table removeFromSuperview];
        //[playersTable.table release];
        playersTable.table = nil;
        playerPickerShown = NO;
        [self returnSubsAndThings];
    }
    
}

- (void)achievementsButtTapped:(id)sender{
    [self buttClickSounds];
    if (!achievementsShown && menusAreActive) {
        [self removeSubViewsAndThings];
        achievementsTable = [[AchievementsTable alloc] init];
        [[[CCDirector sharedDirector] openGLView] addSubview:achievementsTable.table];
        achievementsShown = YES;
        
    }else {
        [achievementsTable.table removeFromSuperview];
        //[achievementsTable.table release];
        achievementsTable.table = nil;
        achievementsShown = NO;
        [self returnSubsAndThings];
    }
    
}
- (void)buttClickSounds{
    //scroll through a few different button click sounds
    
    /*
    if (clickCount == 4) {
        clickCount = 0;
    }
    [[SimpleAudioEngine sharedEngine] playEffect:[clickArr objectAtIndex:clickCount] pitch:1 pan:0.5 gain:1];
    clickCount++;
     */
    [[SimpleAudioEngine sharedEngine] playEffect:@"generalClick.mp3"];
}
- (void)removeSubViewsAndThings{
    
    if (!nameField.isHidden) {
        nameField.hidden = YES;
    }
    if (ship.visible) {
        ship.visible = NO;
    }
    if (_label.visible) {
        _label.visible = NO;
    }
    
    if (hiScoreShown) {
        [hiScoreTable.scoresTable removeFromSuperview];
        //[hiScoreTable.scoresTable release];
        hiScoreTable.scoresTable = nil;
        hiScoreShown = NO;
        
        [debugTable.table removeFromSuperview];
        //[debugTable.table release];
        debugTable.table = nil;
    }
    if (playerPickerShown) {
        [playersTable.table removeFromSuperview];
        //[playersTable.table release];
        playersTable.table = nil;
        playerPickerShown = NO;
    }
    if (goonPickerShown) {
        [goonsTable.table removeFromSuperview];
        //[playersTable.table release];
        goonsTable.table = nil;
        goonPickerShown = NO;
    }
    if (fbPlayerPickerShown){
        [fbPlayerPicker.table removeFromSuperview];
        //[fbPlayerPicker.table release];
        fbPlayerPicker.table = nil;
        fbPlayerPickerShown = NO;
    }
    if (achievementsShown){
        [achievementsTable.table removeFromSuperview];
        //[achievementsTable.table release];
        achievementsTable.table = nil;
        achievementsShown = NO;
    }
}
- (void)returnSubsAndThings{
    if (nameField.isHidden) {
        nameField.hidden = NO;
    }
    if (!ship.visible) {
        ship.visible = YES;
    }
    if (!_label.visible) {
        _label.visible = YES;
    }
}
- (void)musicOnOrOff{
    if (!appDelegate.musicOn) {
        appDelegate.musicOn = YES;
        NSLog(@"music on");
        [musicLab setString:@"Music On"];
        
        //CGPoint pos = [optionsMenu convertToWorldSpace:musicLab.position];
        //musicLab.position = ccp(winSize.width*.99, pos.y);
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1];
    }else{
        appDelegate.musicOn = NO;
        NSLog(@"music off");
        [musicLab setString:@"Music Off"];
        
        //CGPoint pos = [optionsMenu convertToWorldSpace:musicLab.position];
        //musicLab.position = ccp(winSize.width*.99, pos.y);
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
    }
    [optionsMenu alignItemsVerticallyWithPadding:20];
}
- (void)FXOnOrOff{
    if (!appDelegate.FXOn) {
        appDelegate.FXOn = YES;
        NSLog(@"Sounds on");
        [FXLab setString:@"Sounds On"];
        
        //CGPoint pos = [optionsMenu convertToWorldSpace:FXLab.position];
        //FXLab.position = ccp(winSize.width*.99, pos.y);
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
    }else{
        appDelegate.FXOn = NO;
        NSLog(@"Sounds off");
        [FXLab setString:@"Sounds Off"];
        
        //CGPoint pos = [optionsMenu convertToWorldSpace:FXLab.position];
        //FXLab.position = ccp(winSize.width*.99, pos.y);
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    }
    [optionsMenu alignItemsVerticallyWithPadding:20];
}
#pragma mark UIALERTVIEW STUFF
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        NSLog(@"said no with index");
    }
    else if (buttonIndex == 1){
        NSLog(@"said yes to clear");
        [Achievments deleteAllFiles];
        [appDelegate.achievementsArray removeAllObjects];
        appDelegate.achievementsArray = [NSMutableArray arrayWithArray:[Achievments loadDataFromDisk]];
    }
}
// ==================================== Facebook Methods ====================================//
// ==================================== Facebook Methods ====================================//
- (void)facebookStuff{
    facebook = [[Facebook alloc] initWithAppId:@"273872142714164" andDelegate:self];
    appDelegate.facebook = facebook;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        NSLog(@"FB accessToken exists: %@",[facebook accessToken]);
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }else{
        NSLog(@"FB accessToken does NOT exists");
    }
    if (![facebook isSessionValid]) {
        NSLog(@"FB session not valid, requesting authorization");
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                //@"user_likes",
                                //@"user_birthday",
                                //@"email",
                                @"publish_stream",
                                @"publish_actions",
                                @"user_photos",
                                @"friends_photos",
                                nil];
        [facebook authorize:permissions];
        [permissions release];
        permissions = nil;
        //[facebook authorize:nil];
    }else{
        NSLog(@"fb session is already valid");
        if ([appDelegate.faceBookFriendsData count] == 0) {
            //call facebook to get array of friends
            
            [facebook requestWithGraphPath:@"me/friends"
                                 andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"name,picture,id", @"fields", nil]
                               andDelegate:self];
            
        }
    }
    /*
     fbFriendHandler = [[Facebook alloc] init];
     [fbFriendHandler requestWithGraphPath:@"me/friends"
     andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"picture, id, name", @"fields", nil]
     //andHttpMethod:@"GET" //doesn't seem to be necessary
     andDelegate:self];
     */
    
}
#pragma mark DELEGATE METHODS
// ============ FB Delegate Methods ============ //
// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}
// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url];
}
- (void)fbDidLogin {
    NSLog(@"FB did login");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    
    if ([appDelegate.faceBookFriendsData count] == 0) {
        //call facebook to get array of friends
        [facebook requestWithGraphPath:@"me/friends"
                             andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"name,picture,id", @"fields", nil]
                           andDelegate:self];
    }
    
}
- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{NSLog(@"fbDidExtendToken");}
- (void)fbDidLogout{NSLog(@"fbDidLogout");}
- (void)fbDidNotLogin:(BOOL)cancelled{NSLog(@"fbDidNotLogin");}
- (void)fbSessionInvalidated{NSLog(@"fbSessionInvalidated");}
- (void)requestLoading:(FBRequest *)request{
    NSLog(@"FB Intro Scene requestLoading");
    NSLog(@"request: %@",request);
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"FB didReceiveResponse");
}
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    NSLog(@"FB didLoadRawResponse");
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"FB Intro Scene didLoad");
    NSArray *friendsData = [result objectForKey:@"data"];
    //  NSLog(@"friends Data:\n%@", friendsData);
    for (NSDictionary *friend in friendsData) {
        NSString *currentName = [friend objectForKey:@"name"];
        NSString *currentID = [friend objectForKey:@"id"];
        NSString *smallPicUrl = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        NSDictionary *friendDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   currentName, @"name", smallPicUrl, @"url", smallPicUrl, @"thumbUrl", currentID, @"id", nil];
        [appDelegate.faceBookFriendsData addObject:friendDic];
        [friendDic release];
        }
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request failed with error");
    NSLog(@"%@",[error localizedDescription]);
}

// ==================================== TextField Methods ====================================//
// ==================================== TextField Methods ====================================//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [[CCDirector sharedDirector] drawScene];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    //Terminate editing
    [[CCDirector sharedDirector] drawScene];
    playerName = [NSString stringWithFormat:@"%@",nameField.text];
    NSLog(@"nameChanged=%@",playerName);
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField*)textField {
    if (textField==nameField) {
        [nameField endEditing:YES];
        //set current player name for hi score tracking
        playerName = [NSString stringWithFormat:@"%@",nameField.text];
        NSMutableArray *nameArr = [[NSMutableArray alloc] init];
        [nameArr addObject:playerName];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
        appDelegate.gameNameArray = nameArr;
        
        //save current user in defualts
        [[NSUserDefaults standardUserDefaults] setObject:playerName forKey:@"currentUser"];
        
        [nameArr release];
    }
}
// ==================================== Camera Methods ====================================//
// ==================================== Camera Methods ====================================//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"didFinishPickingMediaWithInfo called");
    //[cameraViewCon dismissModalViewControllerAnimated:YES];
    
    [cameraViewCon.view removeFromSuperview];
    [self returnSubsAndThings];
    [picker.view removeFromSuperview];
    [cameraViewCon release];
    cameraViewCon = nil;
    UIImage *camImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelectorInBackground:@selector(detectFacesAndSaveImageWithInfo:) withObject:camImage];
    menusAreActive = YES;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"imagePickerControllerDidCancel called");
    
    [cameraViewCon.view removeFromSuperview];
    [self returnSubsAndThings];
    [picker.view removeFromSuperview];
    [cameraViewCon release];
    cameraViewCon = nil;
    menusAreActive = YES;
}
- (void)detectFacesAndSaveImageWithInfo:(UIImage *)info{
    [FaceData createFaceDataObjectsWithImage:info fromSource:@"camera" andName:@"Joe Shmoe"];
}
// ==================================== Table Methods ====================================//
// ==================================== Table Methods ====================================//
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"Intro scroll view scrolled");
    [[CCDirector sharedDirector] drawScene];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
    NSLog(@"scrollViewWillBeginDecelerating");
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
    NSLog(@"scrollViewDidEndDecelerating");
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = shipScroller.frame.size.width;
    int page = floor((shipScroller.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    shipScroller.pageControl.currentPage = page;
}
- (void)dealloc{
    [hiScoreTable release];
    [playersTable release];
    [_backgroundItems release];
    _backgroundItems = nil;
    [_twinkleStars release];
    _twinkleStars = nil;
    //[fb release]; //fucking crashes here
    [super dealloc];
    
}

@end