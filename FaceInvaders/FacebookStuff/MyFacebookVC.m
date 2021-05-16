//
//  MyFacebookVC.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/14/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "MyFacebookVC.h"

@interface MyFacebookVC ()

@end

@implementation MyFacebookVC
@synthesize facebook;
@synthesize profilePic;
@synthesize friendPicker;
@synthesize loggedInUser;
/*
- (id)init{
    self = [super init];
    if (self) {
        facebook = [[Facebook alloc] initWithAppId:@"***REMOVED***" andDelegate:self];
        
        NSLog(@"\nInitialized FACEBOOK! \naccess Token: %@ \n expiration Date: %@\n", [facebook accessToken], [facebook expirationDate]);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        if (![facebook isSessionValid]) {
            [facebook authorize:nil];
        }
    }
    

    return self;
    
}
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //testApp ID = ***REMOVED***, App Secret = ***REMOVED***
        facebook = [[Facebook alloc] initWithAppId:@"***REMOVED***" andDelegate:self];
        
        NSLog(@"\nInitializing Fuckbook bullSHITTTTTTTTTTTT DUDDDE \naccess Token: %@ \n expiration Date: %@\n", [facebook accessToken], [facebook expirationDate]);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        if (![facebook isSessionValid]) {
            [facebook authorize:nil];
            NSLog(@"is NOT SessionValid");
        }else{
            NSLog(@"isSessionValid");
        }
        
        NSLog(@"\naccess Token: %@ \nexpiration Date: %@\n", [facebook accessToken], [facebook expirationDate]);
        
    }
    return self;
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url];
}
// FACEBOOK DELEGATE METHODS
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    NSLog(@"LOGGED INTO FACEBOOK! \naccess Token: %@ \n expiration Date: %@\n", [facebook accessToken], [facebook expirationDate]);
    
}
- (void)fbDidNotLogin:(BOOL)cancelled{
    //did not log on
}
- (void)fbDidLogout{
    //logged out of fb
    
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    NSLog(@"logged out of FB");
}
- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{
    // use to extend access token i assume?
    NSLog(@"use to extend access token i assume?");
}
- (void)fbSessionInvalidated{
    // fb session no longer valid, i assume.
    NSLog(@"fbSessionInvalidated");
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
        //self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
    
    NSLog(@"login view fetched data");
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
