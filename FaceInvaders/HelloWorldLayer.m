//
//  HelloWorldLayer.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 5/31/12.
//  Copyright EychmoTech 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

@implementation HelloWorldLayer
@synthesize explosion;
@synthesize explosionAction;
@synthesize spriteSheet;
CGImageRef UIGetScreenImage(void);
#define ARC4RANDOM_MAX      0x100000000
#define START_SPAWN_FREQUENCY 1.75 //seconds

+ (CCScene *) scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
- (void)onEnterTransitionDidFinish{
    //---- SCHEDULES --- //for respawning sprites and checking for collisions
    spawnFrequency = START_SPAWN_FREQUENCY;//2.5; //initial spawn frequency?
    [self schedule:@selector(gameLogic:) interval:spawnFrequency];
    
    //schedule for adding items to screen (ammo, guns, health, etc.)
    [self schedule:@selector(addItem:) interval:5];
    
    //Check for collisions, accellerometer changes, as much as possible
    [self schedule:@selector(update:)];
    
    //increase score based on survival time
    [self schedule:@selector(increaseScore:) interval:0.05];
    
    //increase the difficulty every so often...
    [self schedule:@selector(increaseDifficulty:) interval:5];
    
    //1 second updater/timer
    [self schedule:@selector(straightTime:) interval:1];
    
    //take pictures periodically (every 8 seconds)
    [self schedule:@selector(scheduledScreenSchots) interval:8];
    
    //add background things
    [self schedule:@selector(addBackgroundSprites) interval:3];
    [self schedule:@selector(addTwinkleStars) interval:1];
    
    
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = YES;
}
- (id)init{
    
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(0, 100, 255, 225)])) {
        
        //debug things
        hasBackground = YES;
        
        
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        CCSpriteBatchNode *mostSS =    [CCSpriteBatchNode batchNodeWithFile:@"THE Sheet dithered.png"];
        [self addChild:mostSS];
        
        //"cache" monster body images (from sprite sheet)
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"THE Sheet dithered.plist"];
        
                
        //set default player bullets
        bullet = [RedLaser projectile];
        bulletType = 0;
        
        updatesPassed = 0;
        develMode = NO;
        playerInvincible = NO;
        aliensInSynchro = 0;
        winSize = [[CCDirector sharedDirector] winSize];
        winRect = CGRectMake(0, 0, winSize.width, winSize.height);
        [self createSpace];
        
        // ------ CREATE NEW MONSTERS BEFORE GAMEPLAY ----- //
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.activeFaceDataArray = [NSMutableArray arrayWithArray:[FaceData activeFaceDataArray]];
        [ScreenshotHandler deleteAllFiles];
        
        //Init stuff for high scores
        NSString *scoreString = [NSString stringWithFormat:@"%ld",currentScore];
        scoreLabBM = [[CCLabelBMFont alloc] initWithString:scoreString fntFile:@"purpleBauh93.fnt"];
        scoreLabBM.anchorPoint = ccp(1, 1);
        scoreLabBM.position = ccp(winSize.width*0.99, winSize.height*0.99);
        [self addChild:scoreLabBM];
        
        messageBoard =  [[CCLabelBMFont alloc] initWithString:@"Begin!" fntFile:@"purpleBauh93.fnt"];
        [self addChild:messageBoard z:10];
        [self presentMessage:@"fuck you"];
        //messageBoard.position = ccp(winSize.width*2, winSize.height*2);
        
        for (CCSprite *letter in messageBoard.children) {
            [self giveFunMotionToSprite:letter];
        }
        
        planetaryKillCounts = [[NSMutableArray alloc] init];
        planetaryGoonCounts = [[NSMutableArray alloc] init];
        
        _targets =          [[NSMutableArray alloc] init];
        _targtsWCmkBodies = [[NSMutableArray alloc] init];
        _projectiles =      [[NSMutableArray alloc] init];
        _badProjectiles =   [[NSMutableArray alloc] init];
        _items =            [[NSMutableArray alloc] init];
        _crashedBagGuys =   [[NSMutableArray alloc] init];
        _spaceDebris =      [[NSMutableArray alloc] init];
        _backgroundsItems = [[NSMutableArray alloc] init];
        _twinkleStars =     [[NSMutableArray alloc] init];
        
        //Add the Player with their ship
        player = [Player monsterInSpace:space];
        player.weaponn = [RedLaser projectile];
        player.weaponn.type = 0;
        player.position = ccp(player.contentSize.width/2 + 40, winSize.height/2);
        player.rocket = [Player rockets];
        player.rocket.anchorPoint = ccp(0.97, 0.5);
        player.rocket.position = ccp(ship.position.x-ship.boundingBox.size.width*0.2, ship.position.y);
        [player.rocket makeFlicker];
        [self addChild:player.rocket];
        
        //ADD PAUSE BUTTON
        gamePaused = NO;
        pauseButton = [CCMenuItemImage itemFromNormalImage:@"pauseButton.png"
                                                         selectedImage:@"pauseButton.png" target:self
                                                              selector:@selector(pauseGame:)];
        pauseButton.position = ccp(pauseButton.contentSize.width/2 + 5, winSize.height - pauseButton.contentSize.height/2 - 5);
        CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
        
        //add player health bar
        
        ammoBulb = [CCSprite spriteWithFile:@"AmmoBarBulb.png"];
        [ammoBulb setPosition:ccp(ammoBulb.contentSize.width/2+5, ammoBulb.contentSize.height/2+5)];
        [self addChild:ammoBulb];
        ammoBar = [[CCSprite alloc] initWithFile:@"AmmoBar.png"];
        [ammoBar setAnchorPoint:ccp(0, 0.5)];
        [ammoBar setPosition:ccp(ammoBulb.position.x + ammoBulb.contentSize.width/2, ammoBulb.position.y)];
        ammoBarMaxSize = ammoBar.contentSize.width;
        
        healthBulb = [CCSprite spriteWithFile:@"HealthBarBulb.png"];
        healthBar = [[CCSprite alloc] initWithFile:@"HealthBar.png"];
        [healthBulb setPosition:ccp(winSize.width - healthBulb.contentSize.width/2 - healthBar.contentSize.width - 5, ammoBulb.position.y)];
        [healthBar setAnchorPoint:ccp(0, 0.5)];
        [healthBar setPosition:ccp(healthBulb.position.x + healthBulb.contentSize.width/2 - 1, healthBulb.position.y)]; //-1 for no gap
        healthBarMaxSize = healthBar.contentSize.width;
        
        //Add star, asteroid particle emitters, texture
        [self addChild:player z:1];
        [self addChild:healthBar z:0];
        [self addChild:ammoBar z:0];
        [self addChild:healthBulb];
        if (hasBackground) {
            [self initBackground];
        }
        
        NSLog(@"checkpoint 6");
        
        isOnPlanet = YES;
        [self enterSpace];
        playerDead = NO;
        autoShootScheduled = NO;
        
        //SOUNDS AND MUSIC
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"goon galaxy theme3.mp3" loop:YES];
	}
    NSLog(@"scene returned");
	return self;
}
- (void)initBackground{
    // ======================================================================================= //
    // ============================= PARALLAX BACKGROUND STUFF =============================== //
    // ======================================================================================= //
    
    //create static background for changing colors at different planets
    
    foregroundNode = [CCParallaxNode node];
    bkrndNode = [CCParallaxNode node];
    terrainNode = [CCParallaxNode node];
    backgroundTerNode = [CCParallaxNode node];
    
    [self addChild:terrainNode z:-1];
    [self addChild:backgroundTerNode z:-2];
    [self addChild:bkrndNode z:-3];
    [self addChild:foregroundNode];
    
    ccColor3B color = [Background randomBrightColor3B];
    colorLayer = [CCLayerColor layerWithColor:ccc4(color.r, color.g, color.b, 255)];
    [self addChild:colorLayer z:bkrndNode.zOrder-1];
    
    //environment sprites
    backgroundSpace1 = [[CCSprite alloc] initWithFile:@"Space.png"];
    backgroundSpace2 = [[CCSprite alloc] initWithFile:@"Space.png"];
    
    
    //background environment objects
    floatMt = [CCSprite spriteWithFile:@"FloatingMountain1.png"];
    floatMt.color = [ImageProcessor lightenSprite:floatMt];
    
    [self setTerrainType];
    
    paraSpeed = 3000;
    
    //CGPoint dustSpeed = ccp(0.1, 0.1);
    CGPoint terrainSpeed = ccp(0.12, 1);
    CGPoint midTerSpd = ccp(0.025, 1);
    CGPoint backTerrSpd = ccp(0.008, 1);
    CGPoint floatMtSpd = ccp(0.006, 1);
    CGPoint spaceSpeed = ccp(0.001, 0.02);
    
    [terrain setColor:[Background randomBrightColor3B]];
    [terrain2 setColor:terrain.color];
    [terrain3 setColor:[Background randomBrightColor3B]];
    [terrain4 setColor:terrain3.color];
    [backTerrain1 setColor:[Background randomBrightColor3B]];
    [backTerrain2 setColor:backTerrain1.color];
    [floatMt setColor:[Background randomBrightColor3B]];
    
    NSLog(@"checkpoint 5");
    
    [terrainNode addChild:terrain z:0 parallaxRatio:terrainSpeed positionOffset:ccp(0, [terrain boundingBox].size.height/2)];
    [terrainNode addChild:terrain2 z:0 parallaxRatio:terrainSpeed positionOffset:ccp([terrain boundingBox].size.width, [terrain boundingBox].size.height/2)];
    
    [terrainNode addChild:terrain3 z:-1 parallaxRatio:midTerSpd positionOffset:ccp(0, [terrain3 boundingBox].size.height/2*t34Shift)];
    [terrainNode addChild:terrain4 z:-1 parallaxRatio:midTerSpd positionOffset:ccp([terrain3 boundingBox].size.width, [terrain4 boundingBox].size.height/2*t34Shift)];
    
    [bkrndNode addChild:backgroundSpace1 z:0 parallaxRatio:spaceSpeed positionOffset:ccp(0,winSize.height/2)];
    [bkrndNode addChild:backgroundSpace2 z:0 parallaxRatio:spaceSpeed positionOffset:ccp(backgroundSpace1.contentSize.width,winSize.height/2)];
    [backgroundTerNode addChild:backTerrain1 z:1 parallaxRatio:backTerrSpd positionOffset:ccp(0, [backTerrain1 boundingBox].size.height/2*btShift)];
    [backgroundTerNode addChild:backTerrain2 z:1 parallaxRatio:backTerrSpd positionOffset:ccp([backTerrain1 boundingBox].size.width, [backTerrain1 boundingBox].size.height/2*btShift)];
    [backgroundTerNode addChild:floatMt z:0 parallaxRatio:floatMtSpd positionOffset:ccp(winSize.width + floatMt.contentSize.width/2, winSize.height*.75)];
    
}
- (void)spriteMoveFinished:(id)sender {
    CPSprite *sprite = (CPSprite *)sender;
    
    [self removeChild:sprite cleanup:YES];
    
    if (sprite.tag == 1) { // target
        [_targets removeObject:sprite];
        NSLog(@"sprite move finished Tag %d", sprite.tag);
    } else if (sprite.tag == 2) { // projectile
        [_projectiles removeObject:sprite];
    }else if (sprite.tag == 3) { //bad prjectile
        [_badProjectiles removeObject:sprite];
    }else if (sprite.tag == 4) { //item
        [_items removeObject:sprite];
    }else if (sprite.tag == 5) {//background images stuff
        [_backgroundsItems removeObject:sprite];
    }else if (sprite.tag == 6) {//twinkle stars images stuff
        [_twinkleStars removeObject:sprite];
    }else if (sprite.tag ==100){//message board stuff
        messageShown = NO;
    }
}
- (void)endGamePlay{
    
    if (!develMode) {
        //SAVE THE GAME SCORE
        //retreive the array of hi scores
        NSString *gameOverMessage = [NSString stringWithFormat:@"Lose."];
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *currentHiScores = appDelegate.gamePlayerDataArray;
        NSMutableArray *currentPlayerDocs = appDelegate.gamePlayerDocArray;
        
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"hiScore" ascending:NO] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSString *playerNameStg = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentUser"];
        
        GamePlayerDoc *currentPlayerDoc = [[GamePlayerDoc alloc] initWithTitle:playerNameStg rating:currentScore];
        currentPlayer = [currentPlayerDoc data];

        BOOL gotHiScore = NO;
        GamePlayer *lowestHiScore;
        //this is NOT FUCKING WORKING. CRASHES FIRST TIME THROUGH. fu8uhowdhkjdshkvahavladbfhvreifuvhekui
        if ([currentHiScores count] > 0) { //avoid crash at first play when there are no hi scores
            NSLog(@"hiScores: %d", [currentHiScores count]);
            currentHiScores = [NSMutableArray arrayWithArray:[currentHiScores sortedArrayUsingDescriptors:sortDescriptors]];
            lowestHiScore = [currentHiScores objectAtIndex:[currentHiScores count]-1];
        }
        
        /*
        if (lowestHiScore.hiScore == 0) {
            lowestHiScore.hiScore = 1; //wtf is this?
        }
        */
        
        NSLog(@"\nlowestHiScore: %ld", lowestHiScore.hiScore);
        if (currentScore >= lowestHiScore.hiScore || [currentHiScores count] <20) {
            
            gotHiScore = YES;
            [currentPlayerDoc saveData];
            NSLog(@"Added hiScore!");
            gameOverMessage = [NSString stringWithFormat:@"hi score, %@", playerNameStg];
            
            //delete the lowest GamePlayerDoc hi score
            if ([currentHiScores count] > 20) {
                for (GamePlayerDoc *lowScoreDoc in currentPlayerDocs) {
                    
                    NSLog(@"\nlowestHiScore: %ld \nlowScoreDoc: %ld",lowestHiScore.hiScore, lowScoreDoc.data.hiScore);
                    
                    if (lowScoreDoc.data.hiScore <= lowestHiScore.hiScore) {
                        [lowScoreDoc deleteDoc];
                        NSLog(@"Deleted doc");
                    }
                }
            }
        }
        
        if (gotHiScore) {
            NSLog(@"Added score to array");
            [currentHiScores addObject:currentPlayer];
        }
        
        //Sort the high scores
        NSArray *sortedHiScores = [currentHiScores sortedArrayUsingDescriptors:sortDescriptors];
        NSMutableArray *newHighScores = [[NSMutableArray alloc] init];
        for (int i = 0; i<20; i++) {
            if (i>=[sortedHiScores count]) {
                break;
            }
            [newHighScores addObject:[sortedHiScores objectAtIndex:i]];
        }
        
        //replace the hiScores with the sorted list
        appDelegate.gamePlayerDataArray = newHighScores;
        
        //MEMORY CLEAN UP
        [newHighScores release]; newHighScores = nil;
        [currentPlayerDoc release]; currentPlayerDoc = nil;
        float accuracy = (shotsLanded/shotsFired)*100;
        
        appDelegate.gameOverMessage = [NSString stringWithFormat:@"Score: %ld \nKills: %d \nAccuracy: %.f%% \nCoins:%d \nPlanets:%d \n%@",currentScore, kills, accuracy, coinsCollected, planetsVisited, gameOverMessage];
        
        NSMutableDictionary *gameStats = [[NSMutableDictionary alloc] init];
        
        [gameStats setObject:[NSNumber numberWithInt:currentScore] forKey:@"currentScore"];
        [gameStats setValue: [NSNumber numberWithInt:kills] forKey:@"totalKills"];
        [gameStats setValue: [NSNumber numberWithFloat:accuracy]  forKey:@"accuracy"];
        [gameStats setValue:[NSNumber numberWithInt:coinsCollected]  forKey:@"coinsCollected"];
        [gameStats setValue:[NSNumber numberWithInt:planetsVisited] forKey:@"planetsVisited"];
        [gameStats setObject:planetaryKillCounts forKey:@"planetaryKillCounts"]; //number of kills on each planet
        [gameStats setObject:planetaryGoonCounts forKey:@"planetaryGoonCounts"]; //number of goons appearing on each planet
        [gameStats setObject:[NSNumber numberWithInt:planetsVisitedWithoutWrench] forKey:@"planetsVisitedWithoutWrench"];
        appDelegate.gameStatsDic = gameStats;
        NSMutableArray *achievements = [NSMutableArray arrayWithArray:[Achievments achievementsWithData:gameStats]];
        if ([achievements count] > 0) {
            //reload achievements array from file if changes were made to the achievements files
            appDelegate.achievementsArray = [NSMutableArray arrayWithArray:[Achievments loadDataFromDisk]];
            appDelegate.currentAchievements = achievements;
            NSLog(@"currentAchievements: %@", achievements);
        }
        [gameStats release];
        gameStats = nil;
        
        
        //GameOverScene *gameOverScene = [GameOverScene node];
        //gameOverScene.layer.message = gameOverMessage;
        //[[CCDirector sharedDirector] replaceScene:gameOverScene];
        [self unschedule:@selector(gameLogic:)];
        [self unschedule:@selector(increaseScore:)];
        [self unschedule:@selector(straightTime:)];
        [self unschedule:@selector(increaseDifficulty:)];
        [self unschedule:@selector(scheduledScreenSchots)];
        [self unschedule:@selector(addItem:)];
        
        //remove certain things (HUD) for nice look
        [self removeChild:scoreLabBM cleanup:YES];
        pauseButton.visible = NO;
        [self removeChild:pauseButton cleanup:YES];
        [self removeChild:healthBar cleanup:YES];
        [self removeChild:healthBulb cleanup:YES];
        [self removeChild:ammoBar cleanup:YES];
        [self removeChild:ammoBulb cleanup:YES];
        messageBoard.visible = NO;
        
        GameOverLayer *layer = [[GameOverLayer alloc] init];
        [self addChild:layer z:10];
         
    }
}
- (void)explode{
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.mp3"];
}
- (void)playerTakeHit{
    if (!playerInvincible && !playerDead) {
    
        player.hp --;
        playerInvincible = YES; //make player briefly invincible
        playerHit = YES;
        // do some effects here...
        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.05 angle:20];
        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-40];
        id notInvinc = [CCCallFunc actionWithTarget:self selector:@selector(notInvincibleAnymore)];
        CCDelayTime  *wait = [CCDelayTime actionWithDuration:3];
        [player runAction:[CCSequence actions:[CCRepeat actionWithAction:[CCSequence actions:rotRight, rotLeft, rotRight, nil] times:1], notInvinc, wait, nil]];
        
        //change the health bar here...
        float scale = (float)player.hp/player.hpMax;
        //[healthBar setTextureRect:CGRectMake(0, 0, healthBarMaxSize - healthBarMaxSize*(1-scale), healthBar.contentSize.height)];
        healthBar.scaleX = scale;
        NSLog(@"health = %.02f",(float)player.hp);
        
        //take screen shot
        //[self performSelectorInBackground:@selector(screenshot) withObject:nil];
        //[self screenshot];
        [player makeFlicker];
        
        if (player.hp < 0) {
            playerDead = YES;
            
            self.isAccelerometerEnabled = NO;
            //add animation and stuff for a dramatic finish
            [player runAction:[CCRotateBy actionWithDuration:2 angle:720]];
            [player runAction:[CCScaleBy actionWithDuration:2 scale:15]];
            [player runAction:[CCMoveTo actionWithDuration:2 position:ccp(winSize.width*3/4, winSize.height/2)]];
            [player runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.5],[CCFadeOut actionWithDuration:3], [CCCallFunc actionWithTarget:self selector:@selector(endGamePlay)], nil]];
            
            //STOP MUSIC
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            //add death sound FXs
            [[SimpleAudioEngine sharedEngine] playEffect:@"playerDeath.mp3"];
            
        }
    }
}
- (void)scheduledScreenSchots{
    [self performSelectorInBackground:@selector(screenshot) withObject:nil];
}
- (void)screenshot{
    
    CGImageRef screen = UIGetScreenImage();
    
    UIImage *screenImg = [UIImage imageWithCGImage:screen];
    UIImage *img = [UIImage imageWithCGImage:screenImg.CGImage scale:1 orientation:UIImageOrientationLeft];
    
    //EAGLView *eagV = [[EAGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //UIImage *img = [self snapshot:eagV];
    //save with a random digit to avoid overwriting (kinda a cop-out)
    NSString *screenshotFileName = [NSString stringWithFormat:@"screenshot_%d%d%d%d%d%d%d",
                                  arc4random()%9,
                                  arc4random()%9, arc4random()%9,
                                  arc4random()%9, arc4random()%9,
                                  arc4random()%9, arc4random()%9];
    
    NSString *screenshotPath = [[ScreenshotHandler screenShotDir] stringByAppendingPathComponent:screenshotFileName];
    
    //archive screenshot
    [NSKeyedArchiver archiveRootObject:img toFile:screenshotPath];
    
    //CGImageRelease(screen);
    //other working code, bug causes flicker.
    /*
    //istarchenkov credit, http: //www.cocos2d-iphone.org/forum/topic/1722/page/4
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CCLayerColor* blackPage = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0) width:winSize.width height:winSize.height];
    blackPage.position = ccp(winSize.width/2, winSize.height/2);
    
    CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [rtx begin];
    [blackPage visit];
    [[[CCDirector sharedDirector] runningScene] visit];
    [rtx end];
    
    [appDelegate.picturesFromGamePlay addObject:[rtx getUIImageFromBuffer]];
     */
    
}
//static inline double radians (double degrees) {return degrees * M_PI/180;}
- (UIImage*)snapshot:(UIView*)eaglview{
	GLint backingWidth, backingHeight;
    
	// Bind the color renderbuffer used to render the OpenGL ES view
	// If your application only creates a single color renderbuffer which is already bound at this point,
	// this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
	// Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    // In Cocos2D the render-buffer is already binded (and it's a private property...).
    //	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
	// Get the size of the backing CAEAGLLayer
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
	NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
	NSInteger dataLength = width * height * 4;
	GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
	// Read pixel data from the framebuffer
	glPixelStorei(GL_PACK_ALIGNMENT, 4);
	glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
	// Create a CGImage with the pixel data
	// If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
	// otherwise, use kCGImageAlphaPremultipliedLast
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref = CGImageCreate (
                                     width,
                                     height,
                                     8,
                                     32,
                                     width * 4,
                                     colorspace,
                                     // Fix from Apple implementation
                                     // (was: kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast).
                                     kCGBitmapByteOrderDefault,
                                     ref,
                                     NULL,
                                     true,
                                     kCGRenderingIntentDefault
                                     );
    
	// OpenGL ES measures data in PIXELS
	// Create a graphics context with the target size measured in POINTS
	NSInteger widthInPoints, heightInPoints;
	if (NULL != UIGraphicsBeginImageContextWithOptions)
	{
		// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
		// Set the scale parameter to your OpenGL ES view's contentScaleFactor
		// so that you get a high-resolution snapshot when its value is greater than 1.0
		CGFloat scale = eaglview.contentScaleFactor;
		widthInPoints = width / scale;
		heightInPoints = height / scale;
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
	}
	else {
		// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
		widthInPoints = width;
		heightInPoints = height;
		UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
	}
    
	CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
	// UIKit coordinate system is upside down to GL/Quartz coordinate system
	// Flip the CGImage by rendering it to the flipped bitmap context
	// The size of the destination area is measured in POINTS
	CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
	CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
	// Retrieve the UIImage from the current context
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	// Clean up
	free(data);
	CFRelease(ref);
	CFRelease(colorspace);
	CGImageRelease(iref);
    
	return image;
}
- (void)notInvincibleAnymore{//i need a function for this?
    NSLog(@"not invincible");
    playerInvincible = NO;
    playerHit = NO;
}
#pragma mark ADD TARGETS
- (void)addTarget{
    //Select which monster to add
    Monster *target = nil;
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    
    int i = (arc4random() % 6);
    if (i==0 && !isInSpace) {
        target = [Alien     stillSmallAlien];
        [target runAction:[CCSequence actions:[target moveCrossScreen],actionMoveDone, nil]];
        [target positionMonsterOffRightScreen];
        [self addChild:target];
        [_targets addObject:target];
        goonsOnCurrentPlanet++;
    }else if(i==1 && !isInSpace){
        
        target = [SnakeMonster monster];
        [target runAction:[CCSequence actions:[target moveCrossScreen],actionMoveDone, nil]];
        [target positionMonsterOffRightScreen];
        [self addChild:target];
        [_targets addObject:target];
        goonsOnCurrentPlanet++;
    }else if(i==2 && !isInSpace){
        
        target = [Alien stillAlien];
        [target runAction:[CCRepeatForever actionWithAction:[target randomMovesOnScreen]]];
        [target positionMonsterOffRightScreen];
        [self addChild:target];
        [_targets addObject:target];
        goonsOnCurrentPlanet++;
        
    }else if(i==3 && !isInSpace) {
        target = [Alien stillAlien];
        [target runAction:[CCSequence actions:[target moveCrossScreen],actionMoveDone, nil]];
        [target positionMonsterOffRightScreen];
        [self addChild:target];
        [_targets addObject:target];
        goonsOnCurrentPlanet++;
    }else if(i==4 && !isInSpace){
        if (aliensInSynchro <=0 ) {
            [self addBezierAliens];
            NSLog(@"adding Bezier aliens");
        }
    }else if (i==5 && !isInSpace){
            [self addSingleBezierAliens];
            NSLog(@"adding Single Bezier aliens");
    }else if(i==6 && !isInSpace){ //not included currently (11/25/12)
        target = [Alien stillAlien];
        [target positionMonsterOffRightScreen];
        [target giveRandomMovesWithDuration:10];
        
        [self addChild:target];
        [_targets addObject:target];
        goonsOnCurrentPlanet++;
    }
}
- (void)addBezierAliens{
    NSLog(@"adding Bezier alien");
    //isSpecialSequence = YES;
    
    int numOfAlienz = (arc4random() % 5) + 1;
    //constants for the aliens in the sequence
    
    CGPoint pos2 =      [Monster randPositionOnScreen];
    CGPoint pos3 =      [Monster randPositionOnScreen];
    CGPoint pos4 =      [Monster randPositionOnScreen];
    CGPoint pos5 =      [Monster randPositionOnScreen];
    
    NSArray *beziers1 = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAlienz toPoint:pos2]];
    NSArray *beziers2 = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAlienz toPoint:pos3]];
    NSArray *beziers3 = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAlienz toPoint:pos3]];
    NSArray *beziers4 = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAlienz toPoint:pos4]];
    NSArray *beziers5 = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAlienz toPoint:pos5]];
    NSArray *beziers6 = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAlienz toPoint:pos2]];
    
    //NSMutableArray *synchAlienArr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<=numOfAlienz; i++) {
        Monster *alien;
        if (arc4random() % 2 == 1) {
            alien = [Alien stillSmallAlien];
        }else{
            alien = [Alien stillAlien];
        }
        CGPoint strPos = [alien randPositionOffRightScreen];
        
        //motion
        alien.position = strPos;
        id delay = [CCDelayTime actionWithDuration:i*0.5];
        CCSequence *seq = [CCSequence actions:
                           [beziers1 objectAtIndex:i], [beziers2 objectAtIndex:i], [beziers3 objectAtIndex:i],
                           [beziers4 objectAtIndex:i], [beziers5 objectAtIndex:i], [beziers6 objectAtIndex:i], nil];
        [alien runAction:[CCSequence actions:delay, [CCRepeat actionWithAction:seq times:100], nil]];
        alien.isPartOfASynchGroup = YES;
        [_targets addObject:alien];
        [self addChild:alien];
        goonsOnCurrentPlanet++;
    }
    
    [beziers1 release]; beziers1 = nil;
    [beziers2 release]; beziers2 = nil;
    [beziers3 release]; beziers3 = nil;
    [beziers4 release]; beziers4 = nil;
    [beziers5 release]; beziers5 = nil;
    [beziers6 release]; beziers6 = nil;
    aliensInSynchro = numOfAlienz;
    //add to screen n targets array for collision
    
}
- (void)addSingleBezierAliens{
    Monster *a = [Alien stillSmallAlien]; //dummy alien
    
    CGPoint strPos =    [a randPositionOffRightScreen];
    CGPoint endPos = ccp(-a.contentSize.width/2, strPos.y);
    
    int numOfAliens = (arc4random() % 5) + 1;
    NSArray *beziers = [[NSArray alloc] initWithArray:[Monster arrayOfSameBeziers:numOfAliens toPoint:endPos]];
    //id actionMove = [c randomBezierToPoint:endPos];
    
    for (int i=0; i<=numOfAliens; i++) {
        
        Monster *alien;
        if (arc4random() % 2 == 1) {
            alien = [Alien stillSmallAlien];
        }else{
            alien = [Alien stillAlien];
        }
        CGPoint strPos = [alien randPositionOffRightScreen];
        
        alien.position = strPos;
        alien.tag = 1; //target
        alien.isPartOfASynchGroup = YES;
        [_targets addObject:alien];
        [self addChild:alien];
        goonsOnCurrentPlanet++;
        
        id delay = [CCDelayTime actionWithDuration:i*0.25];
        id actionMove = [beziers objectAtIndex:i];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
        [alien runAction:[CCSequence actions:delay, actionMove, actionMoveDone, nil]];
    }
    [beziers release]; beziers = nil;
    aliensInSynchro = numOfAliens;
}
- (void)addBigAlien{
    isSpecialSequence = YES;
    specialAlien = [Alien stillBigAlienInSpace:space];
    specialAlien.isSpecialSequence = YES;
    
    //motion
    [specialAlien runAction:[CCRepeatForever actionWithAction:[specialAlien randomMovesOnScreen]]];
    [specialAlien positionMonsterOffRightScreen];
    
    //[self schedule:@selector(addSpecialProjectile:) interval:0.2];
    
    EvilProjectile *badProjectile =  [EvilProjectile longLaser];
    EvilProjectile *badProjectile2 = [EvilProjectile longLaser];
    
    //add projectile to array
    badProjectile.tag = 3;
    badProjectile2.tag = 3;
    badProjectile.isActive = NO;
    badProjectile2.isActive = NO;
    
    //add to screen n appropriate targets array for collision detection and
    //to update the bodies/sprites for Chipmunk aliens
    if (specialAlien.hasChipmunkBody) {
        [_targtsWCmkBodies addObject:specialAlien];
    }else{
        [_targets addObject:specialAlien];
    }
    
    [self addChild:specialAlien];
    [self updateLasers];
    [self addChild:badProjectile];
    [self addChild:badProjectile2];
    
    badProjectile.visible = NO;
    badProjectile2.visible = NO;
    
    [_badProjectiles addObject:badProjectile];
    [_badProjectiles addObject:badProjectile2];
    
    specialAlien.leftLaser = badProjectile;
    specialAlien.rightLaser = badProjectile2;
    
    id glowEyes =   [CCCallFuncN actionWithTarget:self selector:@selector(glowEyes)];
    id shootLaser = [CCCallFuncN actionWithTarget:self selector:@selector(shootLasers)];
    id unGlowEyes = [CCCallFuncN actionWithTarget:self selector:@selector(unGlowEyes)];
    id endLaser =   [CCCallFuncN actionWithTarget:self selector:@selector(endLaser)];
    id delay =      [CCDelayTime actionWithDuration:3];
    id laserSeq =   [CCSequence actions:glowEyes, delay, shootLaser, delay, delay, endLaser, unGlowEyes, delay, nil];
    
    [specialAlien.leftLaser runAction:  [CCRepeat actionWithAction:laserSeq times:100]];
    [specialAlien.rightLaser runAction: [CCRepeat actionWithAction:laserSeq times:100]];
    
    //logic stuff
    goonsOnCurrentPlanet++;
    killsSinceBigAlienFight = 0;
    [self presentMessage:[NSString stringWithFormat:@"Beware of Goon %@!",specialAlien.fbFriendName]];
}
- (void)addHugeAlien{
    isSpecialSequence = YES;
    specialAlien = [Alien hugeFaceAlienMovingArmsInSpace:space];
    specialAlien.isSpecialSequence = YES;
    NSLog(@"Adding Huge Alien");
    
    //motion
    NSArray *beziers = [Alien arrayOfDifferentBeziers:5];
    id seqOfBez = [CCSequence actionsWithArray:beziers];
    [specialAlien runAction:[CCRepeatForever actionWithAction:seqOfBez]];
    [specialAlien positionMonsterOffBottomScreen];
    
    EvilProjectile *badProjectile =  [EvilProjectile longLaser];
    EvilProjectile *badProjectile2 = [EvilProjectile longLaser];
    
    //add projectile to array
    badProjectile.tag = 3;
    badProjectile2.tag = 3;
    badProjectile.isActive = NO;
    badProjectile2.isActive = NO;
    
    //add to screen behind terrain and add to targets array
    if (specialAlien.hasChipmunkBody) {
        [_targtsWCmkBodies addObject:specialAlien];
    }else{
        [_targets addObject:specialAlien];
    }
    [self addChild:specialAlien z:backgroundTerNode.zOrder];

    
    [self updateLasers];
    [self addChild:badProjectile];
    [self addChild:badProjectile2];
    
    badProjectile.visible = NO;
    badProjectile2.visible = NO;
    
    [_badProjectiles addObject:badProjectile];
    [_badProjectiles addObject:badProjectile2];
    
    specialAlien.leftLaser = badProjectile;
    specialAlien.rightLaser = badProjectile2;
    
    id glowEyes =   [CCCallFuncN actionWithTarget:self selector:@selector(glowEyes)];
    id shootLaser = [CCCallFuncN actionWithTarget:self selector:@selector(shootLasers)];
    id unGlowEyes = [CCCallFuncN actionWithTarget:self selector:@selector(unGlowEyes)];
    id endLaser =   [CCCallFuncN actionWithTarget:self selector:@selector(endLaser)];
    id delay =      [CCDelayTime actionWithDuration:3];
    
    id laserSeq =   [CCSequence actions:glowEyes, delay, shootLaser, delay, delay, endLaser, unGlowEyes, delay, nil];
        
    [specialAlien.leftLaser runAction:  [CCRepeat actionWithAction:laserSeq times:100]];
    [specialAlien.rightLaser runAction: [CCRepeat actionWithAction:laserSeq times:100]];
    
    //logic stuff
    goonsOnCurrentPlanet++;
    killsSinceHugeAlienFight = 0;
    [self presentMessage:[NSString stringWithFormat:@"Beware of Goon\n%@!",specialAlien.fbFriendName]];
}
- (void)glowEyes{
    [specialAlien.leftEye runAction:[CCFadeIn actionWithDuration:3]];
    [specialAlien.rightEye runAction:[CCFadeIn actionWithDuration:3]];
}
- (void)unGlowEyes{
    [specialAlien.leftEye runAction:[CCFadeOut actionWithDuration:0.75]];
    [specialAlien.rightEye runAction:[CCFadeOut actionWithDuration:0.75]];
}
- (void)shootLasers{
    int j = arc4random() % 2;
    
    if (j == 0) {
        specialAlien.leftLaser.visible = YES;
        specialAlien.rightLaser.visible = YES;
        //make active so they will hurt
        specialAlien.leftLaser.isActive = YES;
        specialAlien.rightLaser.isActive = YES;
    }else{
        NSLog(@"schedule addBadProjectile");
        [self schedule:@selector(addBadProjectile:) interval:1];
    }
}
- (void)endLaser{
    specialAlien.leftLaser.visible = NO;
    specialAlien.rightLaser.visible = NO;
    specialAlien.leftLaser.isActive = NO;
    specialAlien.rightLaser.isActive = NO;
    
    [self unschedule:@selector(addBadProjectile:)];
}
- (void)updateLasers{
    
    specialAlien.leftLaser.position = ccp([specialAlien convertToWorldSpace:specialAlien.leftEyePos].x -
                                          specialAlien.leftLaser.contentSize.width/2,
                                          [specialAlien convertToWorldSpace:specialAlien.leftEyePos].y);
    
    specialAlien.rightLaser.position = ccp([specialAlien convertToWorldSpace:specialAlien.rightEyePos].x -
                                           specialAlien.rightLaser.contentSize.width/2,
                                           [specialAlien convertToWorldSpace:specialAlien.rightEyePos].y);
    
}
- (void)draw {
    /*
    drawSpaceOptions options = {
        0, // drawHash
        0, // drawBBs,
        1, // drawShapes
        4.0, // collisionPointSize
        4.0, // bodyPointSize,
        2.0 // lineThickness
     
    };
    
    drawSpace(space, &options);
   */
    
}
#define BULLET_TYPE 1
#define MONSTER_TYPE 2
#define DEBRIS_TYPE 3
- (void)createSpace {
    space = cpSpaceNew();
    space->gravity = ccp(0, 0);
    //optimazation controlling at what resolution physics math is performed
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
    //add collision callbacker
    //cpSpaceAddCollisionHandler(space, 0, 1, (cpCollisionBeginFunc)detectCollision, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(space, BULLET_TYPE, MONSTER_TYPE, detectCollision, NULL, NULL, NULL, NULL);
    
}
static void
postStepRemoveStuff(cpSpace *space, cpShape *al, cpShape *bul)
{
    Alien *alien = (Alien *)al->data;
    Projectiles *proj = (Projectiles *)bul->data;

    
    //    [alien.parent handleD
    HelloWorldLayer *lay = (HelloWorldLayer *)alien.parent;
    [lay handleCollisionOfBullet:proj andMonster:alien];
    
    //deactivate bullet. (removing here causes a crash when the alien is eventually killed).
    proj.visible = NO;
    proj.isActive = NO;
}
static int
detectCollision(cpArbiter *arb, cpSpace *space, void *unused)
{
    // Get the cpShapes involved in the collision
    // The order will be the same as you defined in the handler definition
    // a->collision_type will be BULLET_TYPE and b->collision_type will be MONSTER_TYPE
    cpShape *a, *b; cpArbiterGetShapes(arb, &a, &b);
    
    Projectiles *proj = (Projectiles *)a->data;
    Alien *monster = (Alien *)b->data;
    
    monster.hp = monster.hp - proj.damage;
    NSLog(@"\nCOLLISION: %@ \nHP: %d", monster.fbFriendName, monster.hp);
    
    // Alternatively you can use the CP_ARBITER_GET_SHAPES() macro
    // It defines and sets the variables for you.
    //CP_ARBITER_GET_SHAPES(arb, a, b);
    
    // Add a post step callback to safely remove the body and shape from the space.
    // Calling cpSpaceRemove*() directly from a collision handler callback can cause crashes.
    
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemoveStuff, b, a);
    
    
    
    // The object is dead, don’t process the collision further
    return 0;
}
- (void)addBossFight{
    /*
    //Initiate a BOSS FIGHT here
    NSLog(@"Going to create boss monster in space");
    boss = [FaceWithRedEyes face];
    boss.isBoss = YES;
    //boss.hp = 20;
    //boss.hpMax = 20;
    boss.contentSize = CGSizeMake(200, 200);
    NSLog(@"created boss sprite");
    apendage = [BossMonster monsterInSpace:space];
    NSLog(@"created apendage 1");
    apendage2 = [BossMonster  monsterInSpace:space];
    NSLog(@"created apendage 2");
    apendage3 = [BossMonster monsterInSpace:space];
    
    NSLog(@"created apendage sprites");
    cpBody *anchor1 = cpBodyNewStatic();
    cpBody *anchor2 = cpBodyNewStatic();
    NSLog(@"declared new anchors in space");
    float appWidth = (184.0f - (- 206.0f))*0.15;
        
    cpSpaceAddCollisionHandler(space, 0, 1, (cpCollisionBeginFunc)detectCollision, NULL, NULL, NULL, self);
    
    [boss       createPolygonBodyAtLocation:ccp(winSize.width + (boss.contentSize.width/2), winSize.height/2)
                                  withScale:0.3
                                    inSpace:space];
    [apendage   createPolygonBodyAtLocation:ccp(cpBodyGetPos(boss.body).x + appWidth*1.5, cpBodyGetPos(boss.body).y)
                                  withScale:0.15
                                    inSpace:space];
    [apendage2  createPolygonBodyAtLocation:ccp(cpBodyGetPos(apendage.body).x + appWidth, cpBodyGetPos(boss.body).y)
                                  withScale:0.15
                                    inSpace:space];
    [apendage3  createPolygonBodyAtLocation:ccp(cpBodyGetPos(apendage2.body).x + appWidth, cpBodyGetPos(boss.body).y)
                                  withScale:0.15
                                    inSpace:space];
    NSLog(@"created polygons in space");
    CGPoint bossPos = ccp(winSize.width + (boss.contentSize.width/2), winSize.height/2);    
    CGPoint ap1Pos = ccp(cpBodyGetPos(boss.body).x + appWidth*1.5,  cpBodyGetPos(boss.body).y);
    CGPoint ap2Pos = ccp(cpBodyGetPos(apendage.body).x + appWidth, cpBodyGetPos(boss.body).y);
    CGPoint ap3Pos = ccp(cpBodyGetPos(apendage2.body).x + appWidth, cpBodyGetPos(boss.body).y);

    boss.position = bossPos;
    apendage.position = ap1Pos;
    apendage2.position = ap2Pos;
    apendage3.position = ap3Pos;
    
    boss.body->     shapesList->collision_type = MONSTER_TYPE;
    apendage.body-> shapesList->collision_type = MONSTER_TYPE;
    apendage2.body->shapesList->collision_type = MONSTER_TYPE;
    apendage3.body->shapesList->collision_type = MONSTER_TYPE;
    
    pin = cpPinJointNew(boss.body, apendage.body, cpv(appWidth,0), cpv(-appWidth/2,0));
    pin2 = cpPinJointNew(apendage.body, apendage2.body, cpv(appWidth/2,0), cpv(-appWidth/2,0));
    pin3 = cpPinJointNew(apendage2.body, apendage3.body, cpv(appWidth/2,0), cpv(-appWidth/2,0));
    NSLog(@"created new pins in space");
    anchor1->p = ccp(winSize.width*0.75, winSize.height/2);
    anchor2->p = ccp(winSize.width, winSize.height/2);
    
    dampedSpring1 = cpDampedSpringNew(boss.body,        anchor1, ccp(0, 0), ccp(0, 0), 5, 10, 0.33);
    dampedSpring2 = cpDampedSpringNew(apendage3.body,   anchor2, ccp(0, 0), ccp(0, 0), 5, 10, 0.33);
    NSLog(@"declared new springs in space");
    cpPinJointSetDist(pin, 1);
    cpPinJointSetDist(pin2, 1);
    cpPinJointSetDist(pin3, 1);
    
    cpSpaceAddConstraint(space, pin);
    cpSpaceAddConstraint(space, pin2);
    cpSpaceAddConstraint(space, pin3);
    
    cpSpaceAddConstraint(space, dampedSpring1);
    cpSpaceAddConstraint(space, dampedSpring2);
    NSLog(@"added constraints in space");
    [self addChild:apendage3];
    [self addChild:apendage2];
    [self addChild:apendage];
    [self addChild:boss];
    NSLog(@"added boss and apendages to child");
    boss.tag = 1;
    [_targets addObject:boss];
    goonsOnCurrentPlanet++;
    
    //start the boss shooshting
    [self schedule:@selector(addBadProjectile:) interval:0.2];
    NSLog(@"boss created");
    */
}
- (void)bossTakeHit{
    /*
    float f = 1000;
    cpBodyApplyImpulse(boss.body, ccp(f, 0), ccp(0, 0));
    */ 
}
- (void)bossDestroyed{
    /*
    [boss       destroyBodyinSpace:space]; //because it has a chipmunk body
    [apendage   destroyBodyinSpace:space];
    [apendage2  destroyBodyinSpace:space];
    [apendage3  destroyBodyinSpace:space];

    cpSpaceRemoveConstraint(space, pin);
    cpSpaceRemoveConstraint(space, pin2);
    cpSpaceRemoveConstraint(space, pin3);
    cpSpaceRemoveConstraint(space, dampedSpring1);
    cpSpaceRemoveConstraint(space, dampedSpring2);

    _targetsDestroyed = 0;
    timeSinceBossFight = 0;
    [self unschedule:@selector(addBadProjectile:)];
    isBossFight = NO;
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:10];
    id goToSpace = [CCCallFuncN actionWithTarget:self selector:@selector(enterSpace)];
    [self runAction:[CCSequence actions:delay, goToSpace, nil]];
    
    //Make a new boss for the next round (in background)
    [self performSelectorInBackground:@selector(heavyStuffInBackground) withObject:nil];
    */
}
- (void)addBadProjectile:(ccTime)dt{
    NSLog(@"addBadProjectile called");
    EvilProjectile *badProjectile = [EvilProjectile fireBalls];
    EvilProjectile *badProjectile2 = [EvilProjectile fireBalls];
    
    //add projectile to array
    [_badProjectiles addObject:badProjectile];
    [_badProjectiles addObject:badProjectile2];
    
    //calculate time/vel of laser trip
    float vel = badProjectile.velocity;
    
    //Add first lazer
    float dx1 = [specialAlien convertToWorldSpace:specialAlien.leftEyePos].x;
    badProjectile.position = [specialAlien convertToWorldSpace:specialAlien.leftEyePos];
    CGPoint endPoint = ccp(-badProjectile.contentSize.width/2,[specialAlien convertToWorldSpace:specialAlien.leftEyePos].y);
    
    //calculate end point, past the player to the screen edge;
    float o = [specialAlien convertToWorldSpace:specialAlien.leftEyePos].x - player.position.x;
    float a = [specialAlien convertToWorldSpace:specialAlien.leftEyePos].y - player.position.y;
    float theta = atanf(o/a);
    float yP = dx1/tanf(theta);
    NSLog(@"\no = %.f \na = %.f \nyP = %.2f \ntheta = %.2f", o, a, yP, theta*(360/2*M_PI));
    
    endPoint = player.position;//ccp(-badProjectile.contentSize.width/2,yP - [specialAlien convertToWorldSpace:specialAlien.leftEyePos].y);
    
    [self addChild:badProjectile];
    [badProjectile runAction:[CCSequence actions:
                              [CCMoveTo actionWithDuration:dx1/vel position:endPoint],
                              [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],nil]];
    //Add second lazer
    float dx2 = [specialAlien convertToWorldSpace:specialAlien.rightEyePos].x;
    badProjectile2.position = [specialAlien convertToWorldSpace:specialAlien.rightEyePos];
    //endPoint = ccp(-badProjectile2.contentSize.width/2,[specialAlien convertToWorldSpace:specialAlien.rightEyePos].y);
    [self addChild:badProjectile2];
    [badProjectile2 runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:dx2/vel position:endPoint],
                               [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],nil]];
}
- (void)addSpecialProjectile:(ccTime)dt{
    
    CCSprite *badProjectile = [CCSprite spriteWithFile:@"plasma.png"];
    CCSprite *badProjectile2 = [CCSprite spriteWithFile:@"plasma.png"];
    badProjectile.color = ccc3(255, 0, 0);
    badProjectile2.color = ccc3(255, 0, 0);
    
    //add projectile to array
    badProjectile.tag = 3;
    badProjectile2.tag = 3;
    [_badProjectiles addObject:badProjectile];
    [_badProjectiles addObject:badProjectile2];
    
    //calculate time of laser trip
    float vel = 400; //px/sec

    //Add first lazer
    float dx1 = [specialAlien convertToWorldSpace:specialAlien.leftEyePos].x;//boss.leftEyePos.x;
    badProjectile.position = [specialAlien convertToWorldSpace:specialAlien.leftEyePos];
    CGPoint endPoint = ccp(-badProjectile.contentSize.width/2,
                           [specialAlien convertToWorldSpace:specialAlien.leftEyePos].y);
    [self addChild:badProjectile];
    [badProjectile runAction:[CCSequence actions:
                              [CCMoveTo actionWithDuration:dx1/vel position:endPoint],
                              [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],nil]];
    
    //Add second lazer
    float dx2 = [specialAlien convertToWorldSpace:specialAlien.rightEyePos].x;
    badProjectile2.position = [specialAlien convertToWorldSpace:specialAlien.rightEyePos];
    endPoint = ccp(-badProjectile2.contentSize.width/2,[specialAlien convertToWorldSpace:specialAlien.rightEyePos].y);
    [self addChild:badProjectile2];
    [badProjectile2 runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:dx2/vel position:endPoint],
                               [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],nil]];
}
- (void)addItem:(ccTime)dt{
    //get image for item to be added
    
    int range = (gameDifficulty+1)*2; //this will need to be throttle probably (+1 because gameDiff starts at zero)
    
    if ([_items count] < range) {
        Projectiles *item = [BulletItem item];
        
        // Determine where to spawn the item along the Y axis
        int minY = item.contentSize.height/2;
        int maxY = winSize.height - item.contentSize.height/2;
        int rangeY = maxY - minY;
        int actualY = (arc4random() % rangeY) + minY;
        int actualYdestination = (arc4random() % rangeY) + minY;
        
        // Create the item, random position along the Y axis as calculated above
        item.position = ccp(winSize.width + (item.contentSize.width/2), actualY);
        [self addChild:item];
        NSLog(@"item added with type: %d",item.type);
        //add to mutable array of items
        item.tag = 4;
        [_items addObject:item];
        
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:8 position:ccp(-item.contentSize.width/2, actualYdestination)];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
        [item runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        [item runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2 angle:360]]];
    }else{
        NSLog(@"no item added. too many exist");
    }
}
- (void)addItemAtPos:(CGPoint )itemPos{
    
    //add an item ~ 1/5 times this is called and when no more than 2
    
    int range = (gameDifficulty+1)*7; //this will need to be throttle probably (+1 because gameDiff starts at zero)
    
    if ((arc4random() % range) == 0 && [_items count] < 3) {
        Projectiles *item = [HealthItem item];
        
        // Determine where to spawn the item along the Y axis
        int minY = item.contentSize.height/2;
        int maxY = winSize.height - item.contentSize.height/2;
        int rangeY = maxY - minY;
        int actualYdestination = (arc4random() % rangeY) + minY;
        
        // Create the item, random position along the Y axis as calculated above
        item.position = ccp(itemPos.x, itemPos.y);
        [self addChild:item];
        NSLog(@"Health Item added:");
        //add to mutable array of items
        item.tag = 4;
        [_items addObject:item];
        
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:8 position:ccp(-item.contentSize.width/2, actualYdestination)];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
        [item runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        [item runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2 angle:360]]];
    }
    
    
}
- (void)addCoinsToScene{
    
    CGPoint strPos =    [Monster randPositionOffRightScreen:[Coin item]];//[[Coin item] randPositionOffRightScreen];
    CGPoint endPos;
    //amplitude between 2% and 7% of the height of window
    float ampliude = (((double)arc4random() / ARC4RANDOM_MAX)*0.05 + 0.02) *winSize.height;
    
    int numOfCoins = (arc4random() % 15) + 5;
    float duration = 6000/paraSpeed; //3000 was the defalt, makes duration = 2 seconds by default
    float dlayMulti = 3000/paraSpeed;
    
    for (int i=0; i<=numOfCoins; i++) {
        Projectiles *coin = [Coin item];

        coin.position = ccp(strPos.x, strPos.y + ampliude*cos(i*0.67));
        endPos = ccp(-coin.contentSize.width/2, coin.position.y);
        [self addChild:coin];
        coin.tag = 4;
        [_items addObject:coin];
        
        id delay = [CCDelayTime actionWithDuration:i*0.1*dlayMulti];
        id actionMove = [CCMoveTo actionWithDuration:duration position:endPos];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
        id rotation = [CCRotateBy actionWithDuration:0.3 angle:arc4random()%40 + 2];
        [coin runAction:[CCSequence actions:delay, actionMove, actionMoveDone, nil]];
        [coin runAction:[CCRepeatForever actionWithAction:rotation]];
    }
    NSLog(@"Coin travel Duration: %.2f", duration);
    
}
- (void)addSpaceDebrisToScene{
    
    Projectiles *debris = [EvilProjectile spaceDebris];
    //add projectile to array
    debris.tag = 2;
    [_spaceDebris addObject:debris];
    
    CGPoint strPos =    [Monster randPositionOffRightScreen:[Coin item]];
    [debris createRectBodyAtLocation:strPos withMass:60 inSpace:space];
    debris.body->shapesList->collision_type = BULLET_TYPE;

    debris.body->p = strPos;
    debris.position = strPos;
    
    [self addChild:debris z:-1];
    
    // Determine where we wish to shoot the projectile to
    //float ratio = (float) offY / (float) offX;
    
    float angle = 0;//atanf(ratio);
    debris.body->a = angle;
    
    //rotate the debris. give impulse in x on right edge of body to spin it.
    float impulse = arc4random() % 1000 + 500; //rand between 100,200
    cpBodyApplyImpulse(debris.body, cpv(0, impulse), cpv(debris.boundingBox.size.width/2, 0));
    cpBodyApplyImpulse(debris.body, cpv(0, -impulse), cpv(-debris.boundingBox.size.width/2, 0));
    
    // Move (with impulse) the projectile to actual endpoint
    impulse = ((arc4random() % 4000) + 2000);
    cpBodyApplyImpulse(debris.body, cpv(-impulse, 0), cpv(0, 0)); //dealloced in update i think...
}
- (void)addBackgroundSprites{
    //NSLog(@"timeSinceBackgroundThingsAdded: %d", timeSinceBackgroundThingsAdded);
    if (timeSinceBackgroundThingsAdded > (arc4random() % 4) + 1 /*&& isInSpace*/ && [_backgroundsItems count]<=2) {
        timeSinceBackgroundThingsAdded = 0;
        
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
        NSLog(@"backgroundItem: %d", bk);
        
        [_backgroundsItems addObject:backgroundItem];
        
        // Determine where to spawn the target along the Y axis
        int minY = -backgroundItem.contentSize.height/2;
        int maxY = winSize.height + backgroundItem.contentSize.height/2;
        int rangeY = maxY - minY;
        int actualY = (arc4random() % rangeY) + minY;
        
        // Create the target slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        backgroundItem.position = ccp(winSize.width + (backgroundItem.contentSize.width/2), actualY);
        [backgroundItem setColor:[Background randomDullColor3B]];
        [self addChild:backgroundItem z:-3];
        backgroundItem.tag = 5;
        
        // Determine speed of the target
        int actualDuration = (arc4random() % 13) + 10;
        
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-backgroundItem.contentSize.width/2, actualY)];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
        [backgroundItem runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        
    }
}
- (void)addTwinkleStars{
    NSLog(@"timeSinceBackgroundThingsAdded: %d", timeSinceBackgroundThingsAdded);
    if (timeSinceBackgroundThingsAdded > (arc4random() % 4) + 1 /*&& isInSpace*/ && [_twinkleStars count]<=4) {
        //timeSinceBackgroundThingsAdded = 0;
        
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
        NSLog(@"twinkle star: %d", star);
        
        [_twinkleStars addObject:backgroundItem];
        
        // Determine where to spawn the target along the Y axis
        int minY = -backgroundItem.contentSize.height/2;
        int maxY = winSize.height + backgroundItem.contentSize.height/2;
        int rangeY = maxY - minY;
        int actualY = (arc4random() % rangeY) + minY;
        
        // Create the target slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        backgroundItem.position = ccp(winSize.width + (backgroundItem.contentSize.width/2), actualY);
        
        [self addChild:backgroundItem z:-3];
        backgroundItem.tag = 5;
        
        // Determine speed of the target
        int actualDuration = (arc4random() % 5) + 25;
        
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-backgroundItem.contentSize.width/2, actualY)];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
        [backgroundItem runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    }
}
#pragma mark ENVIRONMENT CHANGES
- (void)enterSpace{
    
    //speed up scene
    id increaseParallax = [CCCallFunc actionWithTarget:self selector:@selector(speedUp)];
    id step = [CCDelayTime actionWithDuration:0.5];
    id seq = [CCSequence actions:increaseParallax, step, nil];
    id speedUp = [CCRepeat actionWithAction:seq times:10];
    
    id chngMoreStuff = [CCCallFunc actionWithTarget:self selector:@selector(changeBackgroundColor)];
    
    if (hasBackground) {
        [backgroundSpace1 runAction:[CCFadeTo actionWithDuration:5 opacity:255]];
        [backgroundSpace2 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:5 opacity:255], chngMoreStuff, speedUp, nil]];
    }
    
    [player runAction:[CCScaleBy actionWithDuration:5 scale:0.5]];
    [player.rocket runAction:[CCScaleBy actionWithDuration:5 scale:0.5]];
    
    terrainHasChanged = NO;
    
    NSNumber *planetKills = [[[NSNumber alloc] initWithInt:killsOnCurrentPlanet] autorelease];
    NSNumber *planetGoons = [[[NSNumber alloc] initWithInt:goonsOnCurrentPlanet] autorelease];
    [planetaryKillCounts addObject:planetKills];
    [planetaryGoonCounts addObject:planetGoons];
}
- (void)speedUp{
    paraSpeed = paraSpeed + 500;
    player.starRockets.speed = player.starRockets.speed + 20;//*(paraSpeed/3000);
    
}
- (void)slowDown{
    paraSpeed = paraSpeed - 500;
    player.starRockets.speed = player.starRockets.speed - 20;//*(paraSpeed/3000);
}
- (void)changeBackgroundColor{
    
    //Change background to start new level... needs work obviously
    timeSinceBackgroundThingsAdded = 0; //brings in planets
    descentToTerrainVel = -30;
    isInSpace = YES;
   
}
- (void)enterNewPlanet{
    
    //slow down scene
    id increaseParallax = [CCCallFunc actionWithTarget:self selector:@selector(slowDown)];
    id step = [CCDelayTime actionWithDuration:0.5];
    id seq = [CCSequence actions:increaseParallax, step, nil];
    id slowDown = [CCRepeat actionWithAction:seq times:10];
    
    descentToTerrainVel = 30;
    isInSpace = NO;
    
    if (hasBackground) {
        [backgroundSpace1 runAction:[CCFadeTo actionWithDuration:5 opacity:100]];//[CCFadeTo actionWithDuration:5 opacity:255]];
        [backgroundSpace2 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:5 opacity:100], slowDown, nil]];
    }
    
    [player runAction:[CCScaleBy actionWithDuration:5 scale:2]];
    [player.rocket runAction:[CCScaleBy actionWithDuration:5 scale:2]];
    
    //score keeping
    planetsVisited++;
    if (wrenchesUsed == 0) {
        //count how many planets the player's been to without using health
        planetsVisitedWithoutWrench++;
    }
    killsOnCurrentPlanet = 0;
    goonsOnCurrentPlanet = 0;
    NSLog(@"ENTERED NEW PLANET");
    [self presentMessage:[NSString stringWithFormat:@"Entering Planet %d",planetsVisited]];
}
- (void)changeTerrainType{
    int i = 2;//arc4random() % 3;

    NSLog(@"changeTerrainType: %d",i);
    if (i == 0) {
        //set as red planet
        terrain =       [CCSprite spriteWithFile:@"SmallRedPlanet.png"];
        terrain2 =      [CCSprite spriteWithFile:@"SmallRedPlanet.png"];
        terrain3 =      [CCSprite spriteWithFile:@"RedPlanet.png"];
        terrain4 =      [CCSprite spriteWithFile:@"RedPlanet.png"];
        backTerrain1 =  [CCSprite spriteWithFile:@"BigRedPlanet.png"];
        backTerrain2 =  [CCSprite spriteWithFile:@"BigRedPlanet.png"];
    }else if(i == 1){
        //set as purple planet
        terrain =       [CCSprite spriteWithFile:@"SmallMountains.png"];
        terrain2 =      [CCSprite spriteWithFile:@"SmallMountains.png"];
        terrain3 =      [CCSprite spriteWithFile:@"MountainsTruncated.png"];
        terrain4 =      [CCSprite spriteWithFile:@"MountainsTruncated.png"];
        backTerrain1 =  [CCSprite spriteWithFile:@"BigMountainsTruncated.png"];
        backTerrain2 =  [CCSprite spriteWithFile:@"BigMountainsTruncated.png"];
    }else if (i == 2){
        //set as mixed planet
        if (arc4random() % 2 == 1) {
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"SmallMountains.png"]]autorelease];
            [terrain  setTexture:tex];
            [terrain2 setTexture:tex];
        }else{
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"SmallRedPlanet.png"]]autorelease];
            [terrain  setTexture:tex];
            [terrain2 setTexture:tex];
        }
        if (arc4random() % 2 == 1) {
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"RedPlanet.png"]]autorelease];
            [terrain3  setTexture:tex];
            [terrain4  setTexture:tex];
        }else{
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"MountainsTruncated.png"]]autorelease];
            [terrain3  setTexture:tex];
            [terrain4  setTexture:tex];
        }
        if (arc4random() % 2 == 1) {
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"BigMountainsTruncated.png"]]autorelease];
            [backTerrain1 setTexture:tex];
            [backTerrain2 setTexture:tex];
        }else{
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"BigRedPlanet.png"]]autorelease];
            [backTerrain1 setTexture:tex];
            [backTerrain2 setTexture:tex];
        }
        
        
    }
}
- (void)setTerrainType{
    int i = arc4random() % 2;
    NSLog(@"set TerrainType: %d",i);
        
    if (i == 0) {
        //set as red planet
        terrain =       [CCSprite spriteWithFile:@"SmallRedPlanet.png"];
        terrain2 =      [CCSprite spriteWithFile:@"SmallRedPlanet.png"];
        terrain3 =      [CCSprite spriteWithFile:@"dummyTerrain.png"];
        terrain4 =      [CCSprite spriteWithFile:@"dummyTerrain.png"];
        backTerrain1 =  [CCSprite spriteWithFile:@"BigRedPlanet.png"];
        backTerrain2 =  [CCSprite spriteWithFile:@"BigRedPlanet.png"];
        floatMt.visible = NO;
    }else if(i ==1){
        //set as purple planet
        CCSpriteBatchNode *terrainSh =    [CCSpriteBatchNode batchNodeWithFile:@"PurpleTerrainSheet.png"];
        [self addChild:terrainSh];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PurpleTerrainSheet.plist"];
        
        /*
        terrain =       [CCSprite spriteWithFile:@"SmallMountains.png"];
        terrain2 =      [CCSprite spriteWithFile:@"SmallMountains.png"];
        terrain3 =      [CCSprite spriteWithFile:@"MountainsTruncated.png"];
        terrain4 =      [CCSprite spriteWithFile:@"MountainsTruncated.png"];
        backTerrain1 =  [CCSprite spriteWithFile:@"BigMountainsTruncated.png"];
        backTerrain2 =  [CCSprite spriteWithFile:@"BigMountainsTruncated.png"];
        */
        terrain =       [CCSprite spriteWithSpriteFrameName:@"SmallMountains.png"];
        terrain2 =      [CCSprite spriteWithSpriteFrameName:@"SmallMountains.png"];
        terrain3 =      [CCSprite spriteWithSpriteFrameName:@"MountainsTruncated2.png"];
        terrain4 =      [CCSprite spriteWithSpriteFrameName:@"MountainsTruncated2.png"];
        backTerrain1 =  [CCSprite spriteWithSpriteFrameName:@"BigMountainsTruncated2.png"];
        backTerrain2 =  [CCSprite spriteWithSpriteFrameName:@"BigMountainsTruncated2.png"];
        
        //shift for terrain that was shaved (because some is always hiddent behind the terrain in front of it).
        t34Shift = 1.26;
        btShift = 1.30;
        
    }else if (i == 2){
        //set as mixed planet
        if (arc4random() % 2 == 1) {
            terrain =       [CCSprite spriteWithFile:@"SmallMountains.png"];
            terrain2 =      [CCSprite spriteWithFile:@"SmallMountains.png"];
        }else{
            terrain =       [CCSprite spriteWithFile:@"SmallRedPlanet.png"];
            terrain2 =      [CCSprite spriteWithFile:@"SmallRedPlanet.png"];
        }
        if (arc4random() % 2 == 1) {
            terrain3 =      [CCSprite spriteWithFile:@"RedPlanet.png"];
            terrain4 =      [CCSprite spriteWithFile:@"RedPlanet.png"];
        }else{
            terrain3 =      [CCSprite spriteWithFile:@"MountainsTruncated.png"];
            terrain4 =      [CCSprite spriteWithFile:@"MountainsTruncated.png"];
        }
        if (arc4random() % 2 == 1) {
            backTerrain1 =  [CCSprite spriteWithFile:@"BigMountainsTruncated.png"];
            backTerrain2 =  [CCSprite spriteWithFile:@"BigMountainsTruncated.png"];
        }else{
            backTerrain1 =  [CCSprite spriteWithFile:@"BigRedPlanet.png"];
            backTerrain2 =  [CCSprite spriteWithFile:@"BigRedPlanet.png"];
        }
        
        
    } else if (i == 6) {
        //set as red planet
        terrain =       [CCSprite spriteWithFile:@"myJunkTerr.png"];//[CCSprite spriteWithFile:@"SmallRedPlanet.png"];
        terrain2 =      [CCSprite spriteWithFile:@"myJunkTerr.png"];
        terrain3 =      [CCSprite spriteWithFile:@"myJunkTerr.png"];
        terrain4 =      [CCSprite spriteWithFile:@"myJunkTerr.png"];
        backTerrain1 =  [CCSprite spriteWithFile:@"myJunkTerr.png"];
        backTerrain2 =  [CCSprite spriteWithFile:@"myJunkTerr.png"];
    }
    
    NSLog(@"\nterrain width: %.f \nterrain2 width: %.f \nterrain3 width: %.f \nterrain4 width: %.f", terrain.boundingBox.size.width, terrain2.boundingBox.size.width, terrain3.boundingBox.size.width, terrain4.boundingBox.size.width);
}
#pragma mark GAME LOGIC
- (void)pauseGame:(id)sender{
    //NSString *gameFont =  appDelegate.gameFont;
    //CGSize size = CGSizeMake(winSize.width/2, 60);
    if (!gamePaused) {
        
        //add layer to dim scene
        pauseLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 150)];
        [self addChild:pauseLayer z:foregroundNode.zOrder+1];
        
        //menu items
        NSString *fntFile = @"purpleBauh93.fnt";
        CCLabelBMFont *resumeButtLab = [CCLabelBMFont labelWithString:@"Resume" fntFile:fntFile];
        CCLabelBMFont *quitButtLab =   [CCLabelBMFont labelWithString:@"Quit"   fntFile:fntFile];
        NSArray *array = [[NSArray alloc] initWithObjects:resumeButtLab, quitButtLab, nil];
        
        //Make buttons
        CCMenuItem *resumeButt =    [CCMenuItemLabel itemWithLabel:resumeButtLab   target:self selector:@selector(resumeGame)];
        CCMenuItem *quitButt =      [CCMenuItemLabel itemWithLabel:quitButtLab     target:self selector:@selector(quitGame)];
        
        //make and add pause menu
        pauseMenu = [CCMenu menuWithItems:resumeButt, quitButt, nil];
        pauseMenu.position = CGPointMake(winSize.width/2, winSize.height/2);
        pauseMenu.contentSize = CGSizeMake(winSize.width/2, winSize.height);
        [pauseMenu alignItemsVerticallyWithPadding:winSize.height*0.1];
        [pauseLayer addChild:pauseMenu z:foregroundNode.zOrder+1];
        
        for (CCLabelBMFont *lab in array) {
            //scale up and right justify with anchor point
            
            for (CCSprite *letter in lab.children) {
                [self giveFunMotionToSprite:letter];
            }
        }
        [array release]; array = nil;
        
        
        NSLog(@"menu should be added");
        [self pauseSchedulerAndActionsRecursive:self];
        gamePaused = YES;
        
        
        
    }else{
        //[[CCDirector sharedDirector] resume];
        //[self resumeSchedulerAndActionsRecursive:self];
        //gamePaused = NO;
    }
}
- (void)quitGame{
    [self removeChild:pauseLayer cleanup:YES];
    [self endGamePlay];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}
- (void)resumeGame{
    [self removeChild:pauseMenu cleanup:YES];
    [self removeChild:pauseLayer cleanup:YES];
    [self resumeSchedulerAndActionsRecursive:self];
    gamePaused = NO;
}
- (void)pauseSchedulerAndActionsRecursive:(CCNode *)node {
    [node pauseSchedulerAndActions];
    for (CCNode *child in [node children]) {
        [self pauseSchedulerAndActionsRecursive:child];
    }
}
- (void)resumeSchedulerAndActionsRecursive:(CCNode *)node {
    [node resumeSchedulerAndActions];
    for (CCNode *child in [node children]) {
        [self resumeSchedulerAndActionsRecursive:child];
    }
}
- (void)gameLogic:(ccTime)dt {//RESPAWN SPRITES
    if (isBossFight) {
        //Start Boss sequence.
    }else if (isSpecialSequence){
        //special stuff
    }else if (!isSpecialSequence && !isBossFight && !isSynchroSequence){
        //add normal bad guys
        [self addTarget];
    }
}
- (void)increaseScore:(ccTime *)dt{
    currentScore ++;
    //update score stuff
    [scoreLabBM setString:[NSString stringWithFormat:@"%ld",currentScore]];
}
- (void)straightTime:(ccTime *)dt{
    
    //keep track of time between boss fights
    //track time between planet fly-bys etc.
    //timeSinceBossFight++;
    timeSinceBackgroundChange++;
    timeSinceBackgroundThingsAdded++;
    
    if (timeSinceBackgroundThingsAdded > 3 && !isInSpace ) {
        
        //[self addCometAlien];
        NSLog(@"addComet Alien called");
        //[floatMt positionMonsterOffRightScreen];
        //[backgroundTerNode addChild:floatMt];
    }
    
    if (arc4random() % 30 == 5 && !isInSpace && timeSinceBackgroundChange>5 && isOnPlanet) {
        [self enterSpace];
        timeSinceBackgroundChange = 0;
    }
    
    
    if (arc4random() % 10 == 1 && isInSpace && timeSinceBackgroundChange>5 && !isOnPlanet) {
        [self enterNewPlanet];
        timeSinceBackgroundChange = 0;
    }
    
}
- (void)increaseDifficulty:(ccTime *)dt{
    //unschedule spawning, then reassign an accelerated spawn rate
    spawnFrequency = 0.99*spawnFrequency;
    [self unschedule:@selector(gameLogic:)];
    [self schedule:@selector(gameLogic:) interval:spawnFrequency];
    
    NSLog(@"difficulty increased: %.02f", spawnFrequency);
}
- (void)update:(ccTime)dt{
    cpSpaceStep(space, dt);//update space? works though...
    /*
    if (isBossFight) {
        [boss update];//update the location of CP body with the sprite
        [apendage update];
        [apendage2 update];
        [apendage3 update];
        
    }
     */
    //update chipmunk collision detection body for sprites with Chipmunk bodies
    for (Monster *mon in _targtsWCmkBodies) {
        [mon updateChipBody];
    }
    for (Projectiles *debris in _spaceDebris) {
        [debris update];
    }
    if (isSpecialSequence) {
        if (specialAlien != nil) {
            [self updateLasers];
        }
    }
    
    //game logic stuff
    if ((arc4random() %900) == 150 && !isSpecialSequence && !isBossFight && !isSynchroSequence
        && !isInSpace && killsSinceBigAlienFight >10) {
        [self addBigAlien];
        isSpecialSequence = YES;
    }
    if ((arc4random() %900) == 150 && !isSpecialSequence && !isBossFight && !isSynchroSequence
        && !isInSpace && killsSinceHugeAlienFight >20) {
        [self addHugeAlien];
        isSpecialSequence = YES;
    }
    if ((arc4random() %60) == 30 && !isSpecialSequence && !isBossFight && !isSynchroSequence && isInSpace) {
        [self addCoinsToScene];
    }
    if ((arc4random() %400) == 10 && !isSpecialSequence && !isBossFight && !isSynchroSequence && isInSpace) {
        [self addSpaceDebrisToScene];
    }
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init]; //ok
    NSMutableArray *badProjectilesToDelete = [[NSMutableArray alloc] init]; //ok
    NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init]; //ok
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init]; //ok
    NSMutableArray *crashedGuysToDelete = [[NSMutableArray alloc] init]; //ok
    NSMutableArray *spaceDebrisToDelete = [[NSMutableArray alloc] init]; //ok
    
    //Code for handling shooting bad guys
    //FOR EACH PROJECTILE...
    for (Projectiles *projectile in _projectiles) {
        [projectile update];
        
        CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2), 
                                           projectile.position.y - (projectile.contentSize.height/2),
                                           projectile.contentSize.width, 
                                           projectile.contentSize.height);
                                           
        BOOL monsterHit = FALSE;
        
        //FOR EACH PROJECTILE, CHECK THE LOCATION OF EACH MONSTER BADGUY
        for (Monster *monster in _targets) {
            //check if any targets are on screen
            if ([_targets count] >0) {
                targetsExist = YES;
            }else targetsExist = NO;
            
            //CHECK FOR AN INTERSECTION BETWEEN EACH PROJECTILE AND EACH ALIEN that doesnt have a CHipmunk bod
            if ([CollisionAssistant detectCollisionBetweenSprite:monster andSprite:projectile] &&
                !monster.hasChipmunkBody && projectile.isActive) {
                
                monsterHit = TRUE;
                [self handleCollisionOfBullet:projectile andMonster:monster];
                
                //Check the targets HP, destroy accordingly.
                if (monster.hp <= 0) {
                    [targetsToDelete addObject:monster];
                }
                break;
            }
        }
        if (monsterHit) {
            [projectilesToDelete addObject:projectile];
            //call collisions FX here...
        }else if (!CGRectIntersectsRect(projectileRect, winRect)) {
            //remove projectiles that are off screen (not touching winSize rect)
            //this should replace the spriteMoveFinished for projectiles
            [projectilesToDelete addObject:projectile];
        }
    }
    
    
    //CHECK FOR COLLISIONS BETWEEN ENEMY FIRE AND PLAYER
    for (EvilProjectile *badProj in _badProjectiles) {
        if ([CollisionAssistant detectCollisionBetweenSprite:player andSprite:badProj] && badProj.isActive) {
            
            //hurt the player, then decide whether to remove the enemy fire.
            [self playerTakeHit];
            if (!badProj.remainsAfterCollision) {
                [badProjectilesToDelete addObject:badProj];
            }
        }
    }
    //CHECK FOR COLLISION BETWEEN BAD GUYS AND PLAYER
    for (Monster *badGuy in _targets) {
        if ([CollisionAssistant detectCollisionBetweenSprite:player andSprite:badGuy] && !badGuy.isBoss && badGuy.canCollideWithPlayer) {
            [self handleDeathOfAlien:badGuy wasCrash:YES];
            [self playerTakeHit];
            [crashedGuysToDelete addObject:badGuy];
        }
    }
    //CHECK FOR COLLISION BETWEEN SPACE DEBRIS AND PLAYER
    for (Projectiles *debris in _spaceDebris) {
        if ([CollisionAssistant detectCollisionBetweenSprite:player andSprite:debris]) {
            //[self handleDeathOfAlien:badGuy wasCrash:YES];
            [self playerTakeHit];
            [spaceDebrisToDelete addObject:debris];
        }
    }
    
    //CHECK FOR CONTACT BETWEEN GOOD ITEMS AND PLAYER
    for (Projectiles *item in _items) {
        if ([CollisionAssistant detectCollisionBetweenSprite:player andSprite:item]) {
            if ([item isKindOfClass:[BulletItem class]]) {
                //bulletType = item.type; //switch to one of the (4) types of bullets
                BulletItem *it = (BulletItem *)item;
                player.weapon = it.type;//[it projectile];
                player.ammo  = MIN(player.ammo + it.ammoAmount, it.maxAmmo);
                player.maxAmmo = it.maxAmmo;
                [self changeWeapon];
                [itemsToDelete addObject:it];
                
                float scale = (float)player.ammo/player.maxAmmo;
                ammoBar.scaleX = scale;
                [self presentMessage:@"Ammo up!"];
                [[SimpleAudioEngine sharedEngine] playEffect:@"item pickup.mp3"];
            }else if ([item isKindOfClass:[HealthItem class]]){
                wrenchesUsed++;
                player.hp = player.hp + 5;
                if (player.hp > player.hpMax) {
                    player.hp = player.hpMax;//if health is greater than max, set to max amount
                }
                //change the health bar here...
                float scale = (float)player.hp/player.hpMax;
                healthBar.scaleX = scale;
                [itemsToDelete addObject:item];
                [[SimpleAudioEngine sharedEngine] playEffect:@"item pickup2.mp3" pitch:1 pan:0.5 gain:1.3];
                [self presentMessage:@"Repaired Ship"];
            }else if (item.isCoin){
                currentScore += 50;
                coinsCollected++;
                [itemsToDelete addObject:item];
                [[SimpleAudioEngine sharedEngine] playEffect:@"coin pickup1.mp3" pitch:1 pan:0.5 gain:0.6];
            }
        }
    }
    
    //Handle targets that have been hit, move to boss fight
    for (CCSprite *target in targetsToDelete) {
        [_targets removeObject:target];
        [target removeFromParentAndCleanup:YES];
    }
    for (CPSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        if(projectile.body != nil){
            [projectile destroyBodyinSpace:space]; //CPSrite removal
        }else{
            [projectile removeFromParentAndCleanup:YES];
        }
    }
    for (CPSprite *debris in spaceDebrisToDelete) {
        [_spaceDebris removeObject:debris];
        if(debris.body != nil){
            [debris destroyBodyinSpace:space]; //CPSrite removal
        }else{
            [debris removeFromParentAndCleanup:YES];
        }
    }
    for (CCSprite *item in itemsToDelete) {
        [_items removeObject:item];
        [self removeChild:item cleanup:YES];
    }
    for (CPSprite *badGuy in crashedGuysToDelete) {
        [_targets removeObject:badGuy];
        [self removeChild:badGuy cleanup:YES];
    }
    for (CCSprite *badProj in badProjectilesToDelete) {
        [_badProjectiles removeObject:badProj];
        [self removeChild:badProj cleanup:YES];
    }
   
    [crashedGuysToDelete release];
    crashedGuysToDelete = nil;
    [itemsToDelete release];
    itemsToDelete = nil;
    [targetsToDelete release];
    targetsToDelete = nil;
    [projectilesToDelete release];
    projectilesToDelete = nil;
    [badProjectilesToDelete release];
    badProjectilesToDelete = nil;
    [spaceDebrisToDelete release];
    spaceDebrisToDelete = nil;
    
    [self accelerometerUpdate:dt];
    
    if (hasBackground) {
        [self parallaxUpdate:dt];
    }

    
}
- (void)handleCollisionOfBullet:(Projectiles *)projectile andMonster:(Monster *)monster{
    
    //NSLog(@"collisione!");
    
    monster.hp = monster.hp - projectile.damage;
    
    currentScore += 100;
    shotsLanded++;
    [self showDamageToMonster:monster atPos:projectile.position];
    //make explosion for bombs
    if (projectile.type == 3) {
        [self makeBombExplodeAtPos:projectile.position];
    }
    
    if (monster.isBoss) {
        [self bossTakeHit];
    }
    //Check the targets HP, destroy accordingly.
    if (monster.hp <= 0 && !monster.isBoss) {
        [self handleDeathOfAlien:monster wasCrash:NO];
    }
}
- (void)handleDeathOfAlien:(Monster *)alien wasCrash:(BOOL)wasCrash{
    //blow it up, get reward
    if ([alien.type isEqualToString:@"HotHead"]) {
        [self makeHotHeadExplodeAtPos:ccp(alien.position.x, alien.position.y)];
    }else{
        //normal explosion
        [self makeExplosionAtPos:ccp(alien.position.x, alien.position.y)];
    }
    
    if (!wasCrash) {
        [self addItemAtPos:ccp(alien.position.x, alien.position.y)];
    }
    
    kills++; //total kills
    killsOnCurrentPlanet++; //kills on current planet
    killsSinceBigAlienFight++; //kills since we faught a boss
    killsSinceHugeAlienFight++; //kills since we faught a "huge" boss
    NSLog(@"Kills =  %d", kills);
    //send messages
    
    if ((kills==10 || kills==20 || kills==60  || kills==100   || kills==150   || kills==200   || kills==300   || kills==400   || kills==500)
        && !messageShown) {
        gameDifficulty++;
        
        NSString *message = [NSString stringWithFormat:@"Killed %d Goons!", kills];
        //[self performSelectorInBackground:@selector(presentMessage:) withObject:message];
        [self presentMessage:message];
        NSLog(@"Killed %@", alien.fbFriendName);
    }
    
    
    NSLog(@"Killed %@", alien.fbFriendName);
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.mp3" pitch:1 pan:0.5 gain:1.5];
    //handle special logic and removals
    if (alien.isSpecialSequence) {
        isSpecialSequence = NO;
        if (alien.hasChipmunkBody) {
            [alien destroyBodyinSpace:space];
            [_targtsWCmkBodies removeObject:alien];
        }else{
            [self removeChild:specialAlien cleanup:YES];
        }
        [self removeChild:specialAlien.leftLaser cleanup:YES];
        [self removeChild:specialAlien.rightLaser cleanup:YES];
        
        [_badProjectiles removeObject:specialAlien.leftLaser];
        [_badProjectiles removeObject:specialAlien.rightLaser];
        [self unschedule:@selector(addBadProjectile:)];
        
        [self presentMessage:[NSString stringWithFormat:@"Killed %@!", alien.fbFriendName]];
    }
    
    //handle sequences/synchronized aliens
    else if (alien.isPartOfASynchGroup) {
        NSLog(@"%c", isSynchroSequence);
        aliensInSynchro --;
        NSLog(@"aliensInSynchro: %d", aliensInSynchro);
        if (aliensInSynchro <= 0) {
            
            isSynchroSequence = NO;
            NSLog(@"%c", isSynchroSequence);
        }
    }
    
    //handle boss destruction
    else if (alien.isBoss){
        [self bossDestroyed];
    }
    
    //GENERAL LOGIC
    //keeping score of destroyed targets
    _targetsDestroyed++;
}
- (void)accelerometerUpdate:(ccTime)dt{
    // ACCELEROMETER STUFF
    //move in y direction
    float currentY = player.position.y;
    float currentX = player.position.x;
    
    float maxY = winSize.height - player.boundingBox.size.height/2;
    float minY = player.boundingBox.size.height/2;
    float newY = player.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    //move in x direction
    float maxX = winSize.width - player.boundingBox.size.width/2;
    float minX = player.boundingBox.size.width/2;
    float newX = player.position.x + (_shipPointsPerSecX * dt);
    newX = MIN(MAX(newX, minX), maxX);
    
    player.position = ccp(newX, newY);
    
    //rotate the ship as it flys. Only do this when, not hit (cuz when hit, it is being rotated)
    if (!playerHit && !playerDead) {
        player.rotation = (currentY-newY)*1.3;
    }
    
    
    player.rocket.position = ccp(player.position.x - player.boundingBox.size.width*0.2, player.position.y);
    float maxRocketScale = 3;
    float minRocketScale = 0.5;
    float scale = MAX( MIN(((newX-currentX)*0.5),maxRocketScale), minRocketScale);
    player.rocket.scaleX = scale;
    
    
    if (arc4random() % 60 == 20) {
        //NSLog(@"rocket.scaleX = %.2f",player.rocket.scaleX);
    }
}
- (void)parallaxUpdate:(ccTime)dt{
    
    //PARALLAX STUFF
    CGPoint foregroundScrollVel = ccp(-paraSpeed, 0);
    CGPoint backgroundScrollVel = ccp(-paraSpeed, 0);
    CGPoint terrainScrollVel = ccp(-paraSpeed, descentToTerrainVel*(paraSpeed/3000));
    CGPoint backTerrScrollVel = ccp(-paraSpeed, descentToTerrainVel*(paraSpeed/3000));
    
    foregroundNode.position =   ccpAdd(foregroundNode.position,         ccpMult(foregroundScrollVel,    dt));
    bkrndNode.position =        ccpAdd(bkrndNode.position,              ccpMult(backgroundScrollVel,    dt));
    terrainNode.position =      ccpAdd(terrainNode.position,            ccpMult(terrainScrollVel,       dt));
    backgroundTerNode.position =ccpAdd(backgroundTerNode.position,      ccpMult(backTerrScrollVel,      dt));
    /*
    NSArray *spaceDusts = [NSArray arrayWithObjects:spaceDust1, spaceDust2, nil];
    for (CCSprite *spaceDust in spaceDusts) {
        if ([foregroundNode convertToWorldSpace:spaceDust.position].x < -spaceDust.contentSize.width) {
            [foregroundNode incrementOffset:ccp(2*spaceDust.contentSize.width,0) forChild:spaceDust];
        }
    }
     */
    
    NSArray *bkSpce = [NSArray arrayWithObjects:backgroundSpace1, backgroundSpace2, /*bkgrndColors1, bkgrndColors2, */nil];
    for (CCSprite *bkSpace in bkSpce) {
        if ([bkrndNode convertToWorldSpace:bkSpace.position].x < -bkSpace.contentSize.width) {
            [bkrndNode incrementOffset:ccp(2*bkSpace.contentSize.width,0) forChild:bkSpace];
        }
    }
    
    NSArray *terrs = [NSArray arrayWithObjects:terrain, terrain2, terrain3, terrain4, nil];
    for (CCSprite *ter in terrs) {
        if ([terrainNode convertToWorldSpace:ter.position].x < -ter.contentSize.width) {
            [terrainNode incrementOffset:ccp(2*ter.contentSize.width,0) forChild:ter];
        }
    }
    NSArray *backTerrs = [NSArray arrayWithObjects:backTerrain1, backTerrain2, nil];
    for (CCSprite *ter in backTerrs) {
        if ([backgroundTerNode convertToWorldSpace:ter.position].x < -ter.contentSize.width) {
            [backgroundTerNode incrementOffset:ccp(2*ter.contentSize.width,0) forChild:ter];
        }
    }
    NSArray *backObj = [NSArray arrayWithObjects: floatMt, nil];
    for (CCSprite *ter in backObj) {
        if ([backgroundTerNode convertToWorldSpace:ter.position].x + ter.contentSize.width < -ter.contentSize.width) {
            [backgroundTerNode incrementOffset:ccp(winSize.width + 2*ter.contentSize.width,0) forChild:ter];
        }
    }
    
    //stop the terrain node from moving too far below the screen and change colors when hidden...
    if (terrainNode.position.y  < -winSize.height && isInSpace && !terrainHasChanged) {
        
        descentToTerrainVel = 0;
        //change colors of terrain when hidden
        
        //[self changeTerrainType]; //huge memory chug - drawing big ass textures
        
        colorLayer.color = [Background randomBrightColor3B];
        //bkgrndColors2.color = bkgrndColors1.color;
        
        terrain.color = [Background randomMatchingColor3BToColor:colorLayer.color];
        terrain2.color = terrain.color;
        terrain3.color = [Background randomMatchingColor3BToColor:terrain.color];
        terrain4.color = terrain3.color;
        backTerrain1.color = [Background randomMatchingColor3BToColor:terrain4.color];
        backTerrain2.color = backTerrain1.color;
        
        floatMt.color = [Background randomMatchingColor3BToColor:terrain.color];
        
        //recolored
        terrain.color = [Background randomMatchingColor3BToColor:terrain4.color];
        terrain2.color = terrain.color;
        
        isOnPlanet = NO;
        terrainHasChanged = YES;
        
    }else if (terrainNode.position.y >= - 10 && !isInSpace) { //if terrain is fully on screen
        descentToTerrainVel = 0;
        isOnPlanet = YES;
    }
}
#pragma mark SCORES and ACHEIVEMENTS

#pragma mark SHOOTING METHODS
- (void)fire{
    
    //check if player has ammo for upgrade, if not, downgrade.
    if (player.ammo<=0 && player.weapon != 0) {
        player.weapon = 0;//[RedLaser projectile];
        ammoBar.color = ccc3(100, 30, 0);
        ammoBar.scaleX = 1;
        [self changeWeapon];
    }
    //PLAY SOUND FX WHEN TOUCHES
    //[[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    
    if (player.weapon == 0) {
        bullet = [RedLaser          projectile];
        [[SimpleAudioEngine sharedEngine] playEffect:@"laser1.mp3" pitch:1 pan:0.5 gain:0.2];
    }else if (player.weapon == 1) {
        bullet = [GreenLaser        projectile];
        [[SimpleAudioEngine sharedEngine] playEffect:@"sharp laser.mp3" pitch:1 pan:0.5 gain:0.2];
        player.ammo--;
    }else if (player.weapon == 2) {
        bullet = [PurpleCurvyLaser  projectile];
        [[SimpleAudioEngine sharedEngine] playEffect:@"soft laser.mp3" pitch:1 pan:0.5 gain:0.6];
        player.ammo--;
    }else if (player.weapon == 3) {
        bullet = [FaceProjectile    projectile];
        [[SimpleAudioEngine sharedEngine] playEffect:@"evil laser.mp3" pitch:1 pan:0.5 gain:0.6];
        player.ammo--;
    }
    
    [bullet createRectBodyAtLocation:player.position inSpace:space];
    bullet.body->shapesList->collision_type = BULLET_TYPE;
    
    //add projectile to array
    bullet.tag = 2;
    [_projectiles addObject:bullet];
    
    bullet.body->p = player.position;
    bullet.position = player.position;
    
    // Determine offset of location to projectile
    int offX = shootingPoint.x - bullet.body->p.x;
    //int offY = shootingPoint.y - bullet.body->p.y;
    
    // If we are shooting backwards, handle
    int i = 1;
    if (offX <= 0){
        i = -1;
    }
    
    // Ok to add now - we've double checked position
    [self addChild:bullet z:-1];
    
    // Determine where we wish to shoot the projectile to
    //float ratio = (float) offY / (float) offX;
    
    float angle = 0;//atanf(ratio);
    bullet.body->a = angle;
    
    // Determine the components of the projectile vector
    float offRealX = bullet.velocity*cos(angle)*i;
    int offRealY = bullet.velocity*sin(angle)*i;
    
    //rotate the projectile, if its a bomb. give impulse in x on right edge of body to spin it.
    if (player.weapon == 3) {
        float impulse = arc4random() % 5 + 1; //rand between -15, 15
        cpBodyApplyImpulse(bullet.body, cpv(0, impulse), cpv(bullet.boundingBox.size.width/2, 0));
        cpBodyApplyImpulse(bullet.body, cpv(0, -impulse), cpv(-bullet.boundingBox.size.width/2, 0));
    }
    
    // Move (with impulse) the projectile to actual endpoint
    cpBodyApplyImpulse(bullet.body, cpv(offRealX, offRealY), cpv(0, 0)); //dealloced in update i think...
    
    shotsFired++;
    
    float scl = (float)player.ammo/player.maxAmmo;
    ammoBar.scaleX = scl;

    
}
- (void)changeWeapon{
    if (player.weapon == 0) {
        bullet = [RedLaser          projectile];
    }else if (player.weapon == 1) {
        bullet = [GreenLaser        projectile];
        ammoBar.color = ccc3(10, 100, 0);
    }else if (player.weapon == 2) {
        bullet = [PurpleCurvyLaser  projectile];
        ammoBar.color = ccc3(100, 0, 100);
    }else if (player.weapon == 3) {
        bullet = [FaceProjectile    projectile];
        ammoBar.color = ccc3(100, 100, 0);
    }
    ammoBulb.color = ammoBar.color;
    float interval = bullet.roundsPerSec; //crashed here once for some reason. was shooting (automatic gun)
    interval = 1/interval;
    if (currentShootInterval !=interval) {
        if (isShooting) {
            [self unschedule:@selector(fire)];
            [self schedule:@selector(fire) interval:interval];
            autoShootScheduled = YES;
        }
        currentShootInterval = interval; //update shoot interval for diff gun w/o player lifting finger
        
    }
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!gamePaused) {
        UITouch *touch = [touches anyObject];
        shootingPoint = [touch locationInView:[touch view]];
        shootingPoint = [[CCDirector sharedDirector] convertToGL:shootingPoint];
        
        if (player.weapon == 0) {
            bullet = [RedLaser          projectile];
        }else if (player.weapon == 1) {
            bullet = [GreenLaser        projectile];
        }else if (player.weapon == 2) {
            bullet = [PurpleCurvyLaser  projectile];
        }else if (player.weapon == 3) {
            bullet = [FaceProjectile    projectile];
        }
        
        //if bullet is auto, schedule
        //if (bullet.automatic) {
        float interval = bullet.roundsPerSec;
        interval = 1/interval;
        
        //NSLog(@"interval = %.02f",interval);
        //NSLog(@"roundsPerSec = %.f",bullet.roundsPerSec);
        
        [self fire]; //shoot for one tap
        
        if (!autoShootScheduled || currentShootInterval !=interval) {
            [self schedule:@selector(fire) interval:interval];
            currentShootInterval = interval; //update shoot interval for diff gun w/o player lifting finger
            autoShootScheduled = YES;
            isShooting = YES;
        }else{
            
        }
    }
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //not used because we only shoot straight now
    /*
    if (!gamePaused) {
        UITouch *touch = [touches anyObject];
        shootingPoint = [touch locationInView:[touch view]];
        shootingPoint = [[CCDirector sharedDirector] convertToGL:shootingPoint];
        
        float interval = bullet.roundsPerSec; //crashed here once for some reason. was shooting (automatic gun)
        interval = 1/interval;
        if (currentShootInterval !=interval) {
            [self unschedule:@selector(fire)];
            [self schedule:@selector(fire) interval:interval];
            currentShootInterval = interval; //update shoot interval for diff gun w/o player lifting finger
            autoShootScheduled = YES;
        }
    }
    */
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //end scheduled auto shooting
    if (!gamePaused) {
        [self unschedule:@selector(fire)];
        autoShootScheduled = NO;
        isShooting = NO;
    }
    
    
}



#define kHeroMovementAction 1
#define kPlayerSpeed 100
#define kFilteringFactor 0.1
#define kRestAccelX -0.4
#define kRestAccelY 0
#define kShipMaxPointsPerSec (winSize.height*1.3)
#define kMaxDiffX 0.2
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
   
    
    /*
    if (calibration) {
        restX = acceleration.x;
        NSLog(@"restX = %.2f", restX);
        if (fabsf(restX)>1) {
            restX = fabsf(restX);//-(0.5-fabsf(restX));
        }
        calibration = NO;
        NSLog(@"restX = %.2f", restX);
    }
    */
    UIAccelerationValue rollingX, rollingY;//, rollingZ;
    
    //rollingX not working properly for with the second part of this expression
    //for no fucking reason at all, this went. (after messing with the orientation) bullshit.
    rollingX = (acceleration.x * kFilteringFactor);// + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor);// + (rollingY * (1.0 - kFilteringFactor));
    //rollingZ = (acceleration.z * kFilteringFactor);// + (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = acceleration.x - rollingX;
    float accelY = acceleration.y - rollingY;
    //float accelZ = acceleration.z - rollingZ;
    
    float accelDiff = accelX - kRestAccelX;
    float accelFraction = accelDiff / kMaxDiffX;
    _shipPointsPerSecY = kShipMaxPointsPerSec * accelFraction;
    
            accelDiff = accelY - kRestAccelY;
            accelFraction = accelDiff / kMaxDiffX;
    float slowYFactor = 0.5;
    //negative because motion was observed backwards... works, don't care why.
    _shipPointsPerSecX = - kShipMaxPointsPerSec * slowYFactor * accelFraction;
    
}


// ========================================================================================================================
// ===============================================Start Explosion and Damage Animation ====================================
// ========================================================================================================================
#pragma mark EXPLOSIONS
- (void)showPointsAtPos:(CGPoint )exPos{
    CCSprite *points = [CCSprite spriteWithFile:@"score100.png"];
    points.color = [Background randomBrightColor3B];
    points.position = exPos;
    [self addChild:points];
    CCAnimate *fadeIn  = [CCFadeIn actionWithDuration:0.1];
    CCAnimate *fadeOut = [CCFadeOut actionWithDuration:1];
    CCAnimate *moveToScore = [CCMoveTo actionWithDuration:0.67 position:ccp(winSize.width, winSize.height)];
    id endAnim = [CCCallFuncN actionWithTarget:self selector:@selector(removePointsDisplay:)];
    [points runAction:moveToScore];
    [points runAction:[CCSequence actions:fadeIn, fadeOut, endAnim, nil]];
    
}
- (void)removePointsDisplay:(id)sender{
    CPSprite *sprite = (CPSprite *)sender;
    [self removeChild:sprite cleanup:YES];
}
- (void)showDamageToMonster:(id)sender atPos:(CGPoint)exPos{
    
    Monster *monster = (Monster *)sender;
    if (monster.isSpecialSequence && !monster.isFlickering) {
      
        [monster makeFlicker];
    }
}
- (void)makeExplosionAtPos:(CGPoint )exPos{
    
    //particle emitter set up
    //NSLog(@"Gonna make explosion");
    
    CCParticleExplosion *explosionParEmit = [[[CCParticleExplosion alloc] initWithTotalParticles:40] autorelease];
    
    if (!explosionTexture) { //for when this crap is released in a memory warning
        explosionTexture = [[CCTextureCache sharedTextureCache] addImage:@"explosionPiece.png"];
    }
    
    //explosionParEmit.texture = explosionTexture;
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"plasma.png"];
    [explosionParEmit setTexture:[frame texture] withRect:[frame rect]];

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
   // NSLog(@"made explosion");
    
    //show points
    [self showPointsAtPos:exPos];
     
    
}
- (void)makeBombExplodeAtPos:(CGPoint)puffPos{
    //particle emitter set up
    //NSLog(@"Gonna make explosion");
    
    CCParticleExplosion *explosionPuff = [[[CCParticleExplosion alloc] initWithTotalParticles:10] autorelease];
    //explosionPuff.texture = bombExplodeTexture;
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BombPuff.png"];
    [explosionPuff setTexture:[frame texture] withRect:[frame rect]];
    
    explosionPuff.position = puffPos;
    explosionPuff.autoRemoveOnFinish = YES;
    explosionPuff.speed = 30;//150;
    explosionPuff.speedVar = 10;
    explosionPuff.life = 0.5;
    explosionPuff.lifeVar = 0.2;
    explosionPuff.startSize = frame.rect.size.width*0.7;
    explosionPuff.startSpin = 20;

    
    [self addChild:explosionPuff];
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.mp3"];
    //NSLog(@"made explosion");
    
    //show points
    [self showPointsAtPos:puffPos];
}
- (void)makeHotHeadExplodeAtPos:(CGPoint)puffPos{
    //particle emitter set up
    //NSLog(@"Gonna make explosion");
    
    CCParticleExplosion *explosionPuff = [[[CCParticleExplosion alloc] initWithTotalParticles:5] autorelease];
    //explosionPuff.texture = bombExplodeTexture;
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BigBodyA02.png"];
    [explosionPuff setTexture:[frame texture] withRect:[frame rect]];
    
    explosionPuff.position = puffPos;
    explosionPuff.autoRemoveOnFinish = YES;
    explosionPuff.startColorVar = ccc4FFromccc3B(ccc3(0, 0, 0));
    explosionPuff.endColorVar = ccc4FFromccc3B(ccc3(0, 0, 0));
    explosionPuff.speed = 100;//150;
    explosionPuff.speedVar = 20;
    explosionPuff.life = 0.8;
    explosionPuff.lifeVar = 0.2;
    explosionPuff.startSize = frame.rect.size.width*0.4;
    explosionPuff.startSpin = 20;
    
    
    
    [self addChild:explosionPuff];
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.mp3"];
    //NSLog(@"made explosion");
    
    //show points
    [self showPointsAtPos:puffPos];
}
- (void)spriteSheetEnded:(id)sender{
    NSLog(@"going to remove spriteSheet");
    CCSprite *sprite = (CCSprite *)sender;
    CCSpriteBatchNode *sprtSheet = (CCSpriteBatchNode *)sender;
    [sprtSheet removeChild:sprite cleanup: YES];
    NSLog(@"removed spriteSheet");
}
- (void)particleEmitEnded:(id)sender{
    NSLog(@"going to remove explosion");
    CCParticleExplosion *particleSystem = (CCParticleExplosion *)sender;
    [self removeChild:particleSystem cleanup: YES];
    NSLog(@"removed explosion");
}
//animations
- (void)giveFunMotionToSprite:(id)sender{
    float duration = (((double)arc4random() / ARC4RANDOM_MAX)*1 + 0.75);
    int y = (arc4random() % 5) + 2;
    
    id scaleUpAction =      [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0,  y)] rate:2.0];
    id scaleDownAction =    [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0, -y)] rate:2.0];
    CCSequence *scaleSeq =  [CCSequence actions:scaleUpAction, scaleDownAction, nil];
    
    [sender runAction:[CCRepeatForever actionWithAction:scaleSeq]];
}

- (void)presentMessage:(NSString *)message{
    //CCLabelBMFont *lab = [CCLabelBMFont labelWithString:message fntFile:@"purpleBauh93.fnt"];
    [messageBoard setString:message];
    messageBoard.position = ccp(winSize.width/2, winSize.height+messageBoard.boundingBox.size.height/2);
    CGPoint p1 = messageBoard.position;
    CGPoint p2 = ccp(winSize.width/2, winSize.height*4/5);
    //[self addChild:messageBoard z:10];
    
    id enter    = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:0.25 position:p2] rate:2];
    id delay    = [CCDelayTime actionWithDuration:0.75];
    id exit     = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:0.25 position:p1] rate:2];
    id seq      = [CCSequence actions:enter, delay, exit, nil];
    [messageBoard runAction:seq];
    //messageBoard.tag = 100;
    
    //messageBoard.visible = YES;
    //messageShown = YES;
    NSLog(@"message is: %@ count: %d", message, [messageBoard.children count]);
    //int lCount = 0;
    //float vel = 500; //pixels/sec
    /*
    for (CCSprite *letter in lab.children) {
        lCount++;
        NSLog(@"letter: %@ count: %d", message, [lab.children count]);
        CGPoint posi = [lab convertToNodeSpace:[self randPositionOffRightScreen:letter]];
        
        //keep the velocity the same for all letters;
        float d = ccpDistance(letter.position, posi);
        float t = d/vel;
        
        id delay = [CCDelayTime actionWithDuration:1];
        id zipOffScreen = [CCEaseIn actionWithAction:[CCMoveTo actionWithDuration:t position:posi] rate:2];
        
        id fin = [CCCallBlock actionWithBlock:^{
            if (lCount == [lab.children count]) {
                messageShown = NO;
                messageBoard.visible = NO;
                NSLog(@"message no longer shown");
            }
        }];
        id seq = [CCSequence actions:delay, zipOffScreen, nil];
        NSLog(@"gonna run action");
        [letter runAction:seq];
    }
    */
    /*
    id delay = [CCDelayTime actionWithDuration:2]; //somewhat arbitrary, so long as its after the motions off screen
    id finish   = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    id seq = [CCSequence actions:delay, finish, nil];
    [lab runAction:seq];
    */
}
- (CGPoint)randPositionOffRightScreen:(CCNode *)sprite{
    
    int minY = sprite.contentSize.height/2;
    int maxY = winSize.height - sprite.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    return ccp(winSize.width + (sprite.contentSize.width/2), actualY);
}
- (void)dealloc{   // on "dealloc" you need to release all your retained objects.
	// In case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
    [_targets release];
    _targets = nil;
    [_projectiles release];
    _projectiles = nil;
    [_badProjectiles release];
    _badProjectiles = nil;
    [_items release];
    _items = nil;
    [_crashedBagGuys release];
    _crashedBagGuys = nil;
    [explosionAnimFrames release];
    explosionAnimFrames = nil;
    [_backgroundsItems release];
    _backgroundsItems = nil;
    [_twinkleStars release];
    _twinkleStars = nil;
    [_spaceDebris release];
    _spaceDebris = nil;
    
    //score keeping stuff
    [planetaryKillCounts release];
    planetaryKillCounts = nil;
    
    [scoreLabBM release];
    [backgroundSpace1 release];
    [backgroundSpace2 release];
    //clear out activ e array. this gets regenerated at each start. save memory for heavy
    //image processing and face finding when user in the menu and such
    appDelegate.activeFaceDataArray = nil;
    
    //chipmunk
    NSLog(@"dealloc 8");
    cpSpaceFree(space);
	// don't forget to call "super dealloc
    
    NSLog(@"dealloc 9");
	[super dealloc];
}
@end

