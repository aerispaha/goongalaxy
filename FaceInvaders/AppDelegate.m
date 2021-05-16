//
//  AppDelegate.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 5/31/12.
//  Copyright EychmoTech 2012. All rights reserved.
//

#import "cocos2d.h"
#import "IntroScene.h"
#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"
#import "RootViewController.h"
#import "chipmunk.h"
#import "GamePlayerDatabase.h"
#import "ScreenshotHandler.h"



@implementation AppDelegate
@synthesize window;
@synthesize face;
@synthesize monsterArray;
//@synthesize activeFaceArray;
@synthesize activePlayersIndexString;
@synthesize faceDataArray;
@synthesize activeFaceDataArray;
@synthesize faceBookFriendsData;
@synthesize achievementsArray;
@synthesize appendageArray;
@synthesize bossImg;
@synthesize planetArray;
//@synthesize debrisImgArray;
@synthesize gamePlayer;
@synthesize gameNameArray;
@synthesize gamePlayerDataArray;
@synthesize gamePlayerDocArray;
@synthesize playerD;
@synthesize heroIndex;
@synthesize facebook;
@synthesize viewController;
@synthesize picturesFromGamePlay;
@synthesize debuggerImages;
@synthesize gameOverMessage;
@synthesize gameStatsDic;
@synthesize currentAchievements;
@synthesize gameFont;
@synthesize musicOn;
@synthesize FXOn;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] ){
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	}
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    NSLog(@"rootViewController called");
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
	//viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//

	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0//GL_DEPTH_COMPONENT16_OES//0
                            preserveBackbuffer:NO //not here in default
                                    sharegroup:nil//not here in default
                                 multiSampling:NO //not here in default
                               numberOfSamples:0  //not here in default
						];
	
    //NSLog(@"depth format: %u", glView.depthFormat);
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
        if(![director enableRetinaDisplay:YES])
            CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
    [director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
    /*
#if GAME_AUTOROTATION == kGameAutorotationCCDirector
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
          NSLog(@"CUNT?");
#endif
	*/
    
	[director setAnimationInterval:1.0/60]; //was 1/60
	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    //[self facebookStuff];
    [self myStuff];
    
	// Removes the startup flicker
	[self removeStartupFlicker];
	
    //INITIALIZE CHIPMUNK
    cpInitChipmunk();
    
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [IntroLayer scene]];
}
#pragma mark MY STUFF
// ================================================================================ //
// ================================= MY STUFF ===================================== //
// ================================================================================ //
    
- (void)myStuff{
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
        // Retina display
        NSLog(@"IS RETINA DISPLAY");
    } else {
        // non-Retina display
        NSLog(@"IS NOT RETINA DISPLAY");
    }
    
    //set the game font
    gameFont = [[NSString alloc] initWithFormat:@"Bauhaus 93"];//[[NSString alloc] initWithFormat:@"friendly robot"];
    
    NSLog(@"family names: %@",[UIFont familyNames]);
    
    //Initialize
    // ---------THIS STUFF IS NOT DEALLOCATED I THINK ------ //
    faceDataArray = [[NSMutableArray alloc] initWithArray:[FaceData loadDataFromDisk]]; //array of unified face objects
    activeFaceDataArray = [[NSMutableArray alloc] initWithArray:[FaceData activeFaceDataArray]];
    monsterArray = [[NSMutableArray alloc] init];
    faceBookFriendsData = [[NSMutableArray alloc] init];
    appendageArray = [[NSMutableArray alloc] init];
    planetArray = [[NSMutableArray alloc] init];
    gamePlayerDataArray = [[NSMutableArray alloc] initWithArray:[GamePlayerDatabase loadGamePlayers]];
    gamePlayerDocArray = [[NSMutableArray alloc] initWithArray:[GamePlayerDatabase loadGamePlayerDocs]];
    gameNameArray = [[NSMutableArray alloc] init];
    picturesFromGamePlay = [[NSMutableArray alloc] init];
    debuggerImages = [[NSMutableArray alloc] init];
    playerD = [[GamePlayerDoc alloc] init];
    gameOverMessage = [[NSString alloc] init];
    currentAchievements = [[NSMutableArray alloc] init];
    gameStatsDic = [[NSMutableDictionary alloc] init];
    

    //sound/music defaults (should be in user defaults, but for now, who cares)
    musicOn = YES;
    FXOn = YES;
    
    //deafult hero goon

    
    gamePlayer =    [[NSString alloc] init];
    gamePlayer =    [[NSUserDefaults standardUserDefaults] stringForKey:@"currentUser"];
    heroIndex =     [[NSUserDefaults standardUserDefaults] integerForKey:@"heroIndex"];
    NSLog(@"heroIndex = %d", heroIndex);
    if (gamePlayer ==nil) {
        NSLog(@"gamePlayer is nil");
        
        gamePlayer = [NSString stringWithFormat:@"Player Name"];
        [[NSUserDefaults standardUserDefaults] setObject:gamePlayer forKey:@"currentUser"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"heroIndex"];
    }
    [gameNameArray addObject:gamePlayer];
    
    
    //CREATE DEFAULT HI SCORES IF NONE EXIST
    if ([gamePlayerDataArray count] == 0) {
        
        for (int i = 0; i<20; i++) {
            //Make 20 Adam hi scores at 100
            GamePlayerDoc *currentPlayerDoc = [[GamePlayerDoc alloc] initWithTitle:@"Adam" rating:100];
            //NSLog(@"\ngameplayername: %@\ngameplayerScore: %ld", currentPlayerDoc.playerData.name,currentPlayerDoc.playerData.hiScore);
            [currentPlayerDoc saveData];
            [gamePlayerDataArray addObject:[currentPlayerDoc data]];
            [currentPlayerDoc release];
            currentPlayerDoc = nil;
        }
        //gamePlayerDataArray = [GamePlayerDatabase loadGamePlayers];
        NSLog(@"made gamePlayerDataArray: %@",gamePlayerDataArray);
    }
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    
    //create directory for saving faceData objects
    if(![fileManager fileExistsAtPath:[FaceData faceDataDir]]){
        [FaceData makeFaceDataDir];
        NSLog(@"made Directory: %@",[FaceData faceDataDir]);
    }else{NSLog(@"directory already exists: %@",[FaceData faceDataDir]);}
    
    //create directory for saving faceData images
    if(![fileManager fileExistsAtPath:[FaceData faceDataImagesDir]]){
        [FaceData makeFaceDataImagesDir];
        NSLog(@"made Directory: %@",[FaceData faceDataImagesDir]);
    }else{ NSLog(@"directory already exists: %@",[FaceData faceDataImagesDir]); }
    
    //create directory for achievements
    //[Achievments deleteAllFiles];
    if(![fileManager fileExistsAtPath:[Achievments achievementsDataDir]]){
        [Achievments makeAchievementsDataDir];
        [Achievments createAchievements];
        NSLog(@"made Directory: %@",[Achievments achievementsDataDir]);
    }else{ NSLog(@"directory already exists: %@",[Achievments achievementsDataDir]); }
    achievementsArray = [[NSMutableArray alloc] initWithArray:[Achievments loadDataFromDisk]]; //[NSArray arrayWithArray:[Achievments loadDataFromDisk]];
    NSLog(@"contents of achievementsArray: %@",achievementsArray);
    
    //create directory for saving screen shot images
    if(![fileManager fileExistsAtPath:[ScreenshotHandler screenShotDir]]){
        [ScreenshotHandler makeScreenShotDir];
        NSLog(@"made Directory: %@",[ScreenshotHandler screenShotDir]);
    }else{
        NSLog(@"directory already exists: %@",[ScreenshotHandler screenShotDir]);
        [ScreenshotHandler deleteAllFiles]; //clear out files
    }
    
    
    //sort the faceDataArray?
    /*
    NSMutableArray *unsortedData = [[[NSMutableArray alloc] initWithArray:faceDataArray] autorelease];
    NSLog(@"unsorted data.\ncount: %d",[unsortedData count]);
    
    //sort the fb peeps by name
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    faceDataArray = [[NSMutableArray alloc] initWithArray:[unsortedData sortedArrayUsingDescriptors:sortDescriptors]];
    */
    
}
- (void)facebookStuff{
    facebook = [[Facebook alloc] initWithAppId:@"273872142714164" andDelegate:self];
    
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
        if ([faceBookFriendsData count] == 0) {
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
    
    
    if ([faceBookFriendsData count] == 0) {
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
    NSLog(@"FB requestLoading");
    NSLog(@"request: %@",request);
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"FB didReceiveResponse");
}
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    NSLog(@"FB didLoadRawResponse");
}
- (void)request:(FBRequest *)request didLoad:(id)result{
   
    NSLog(@"FB didLoad");
    NSArray *friendsData = [result objectForKey:@"data"];
    //  NSLog(@"friends Data:\n%@", friendsData);
    for (NSDictionary *friend in friendsData) {
        NSString *currentName = [friend objectForKey:@"name"];
        NSString *currentID = [friend objectForKey:@"id"];
        NSString *smallPicUrl = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        NSDictionary *friendDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   currentName, @"name", smallPicUrl, @"url", smallPicUrl, @"thumbUrl", currentID, @"id", nil];
        [faceBookFriendsData addObject:friendDic];
        [friendDic release];
    }
    
    
    /*
    NSArray *resultData = [result objectForKey:@"data"];
    NSLog(@"resultData (%d): %@",[resultData count], resultData);
    //NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:1];
    //create array of faceBookFriends data
    for (NSUInteger i=0; i<[resultData count]; i++) {
        [faceBookFriendsData addObject:[resultData objectAtIndex:i]];
    }
    //[fbFriendHandler release];
     */
}

#pragma mark Other App Delegate Methods
- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
    
    [monsterArray release];
    //[activeFaceArray release];
    [appendageArray release];
    [planetArray release];
    //[debrisImgArray release];
    [gamePlayerDataArray release];
    [gamePlayerDocArray release];
    [gameNameArray release];
    [picturesFromGamePlay release];
    [debuggerImages release];
    [playerD release];
    [gameFont release];
    
	[super dealloc];
}

@end
