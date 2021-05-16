//
//  FBFunViewController.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/8/12.
//  Credit to Ray Wenderlich Tutorials
//

#import "FBFunViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@interface FBFunViewController ()

@end

@implementation FBFunViewController
@synthesize loginStatusLabel = _loginStatusLabel;
@synthesize loginButton = _loginButton;
@synthesize loginDialog = _loginDialog;
@synthesize loginDialogView = _loginDialogView;

@synthesize textView = _textView;
@synthesize imageView = _imageView;
@synthesize segControl = _segControl;
@synthesize webView = _webView;
@synthesize accessToken = _accessToken;

- (void)dealloc {
    self.loginStatusLabel = nil;
    self.loginButton = nil;
    self.loginDialog = nil;
    self.loginDialogView = nil;
    
    self.textView = nil;
    self.imageView = nil;
    self.segControl = nil;
    self.webView = nil;
    self.accessToken = nil;
    
    [super dealloc];
}

- (void)refresh {
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginStatusLabel.text = @"Not connected to Facebook";
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
    } else if (_loginState == LoginStateLoggingIn) {
        _loginStatusLabel.text = @"Connecting to Facebook...";
        _loginButton.hidden = YES;
    } else if (_loginState == LoginStateLoggedIn) {
        _loginStatusLabel.text = @"Connected to Facebook";
        [_loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (IBAction)loginButtonTapped:(id)sender {
    //testApp ID = **removed**, App Secret = **removed**
    NSString *appId = @"**removed**";
    //for more permissions: http://developers.facebook.com/docs/authentication/permissions/
    NSString *permissions = @"publish_stream";
    
    if (_loginDialog == nil) {
        self.loginDialog = [[[FBFunLoginDialog alloc] initWithAppId:appId
                                               requestedPermissions:permissions delegate:self] autorelease];
        self.loginDialogView = _loginDialog.view;
    }
    
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginState = LoginStateLoggingIn;
        [_loginDialog login];
    } else if (_loginState == LoginStateLoggedIn) {
        _loginState = LoginStateLoggedOut;
        [_loginDialog logout];
    }
    
    [self refresh];
    
}
- (void)accessTokenFound:(NSString *)accessToken {
    NSLog(@"Access token found: %@\n", accessToken);
    self.accessToken = accessToken;
    _loginState = LoginStateLoggedIn;
    [self dismissModalViewControllerAnimated:YES];
    [self getFacebookProfile];
    [self refresh];
}

- (void)displayRequired {
    NSLog(@"\n\ndisplayRequired Called\n");
    [self presentModalViewController:_loginDialog animated:YES];
}

- (void)closeTapped {
    [self dismissModalViewControllerAnimated:YES];
    _loginState = LoginStateLoggedOut;
    [_loginDialog logout];
    [self refresh];
}

//PART II CODE (ray wenderlich)

- (void)getFacebookProfile {
    NSString *urlString = [NSString
                           stringWithFormat:@"https://graph.facebook.com/me?access_token=%@/",
                           [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDidFinishSelector:@selector(getFacebookProfileFinished:)];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)rateTapped:(id)sender {
    
}

- (void)getFacebookProfileFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"Got Facebook Profile: %@", responseString);
    
    NSString *likesString;
    NSMutableDictionary *responseJSON = [responseString JSONValue];
    NSArray *interestedIn = [responseJSON objectForKey:@"interested_in"];
    if (interestedIn != nil) {
        NSString *firstInterest = [interestedIn objectAtIndex:0];
        if ([firstInterest compare:@"male"] == 0) {
            [_imageView setImage:[UIImage imageNamed:@"hassel.png"]];
            likesString = @"dudes";
        } else if ([firstInterest compare:@"female"] == 0) {
            [_imageView setImage:[UIImage imageNamed:@"erinPlayer.png"]];
            likesString = @"babes";
        }
    } else {
        [_imageView setImage:[UIImage imageNamed:@"fuckface.png"]];
        likesString = @"puppies";
    }
    
    NSString *username;
    NSString *firstName = [responseJSON objectForKey:@"first_name"];
    NSString *lastName = [responseJSON objectForKey:@"last_name"];
    if (firstName && lastName) {
        username = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else {
        username = @"mysterious user";
    }
    
    _textView.text = [NSString stringWithFormat:
                      @"Hi %@!  I noticed you like %@, so tell me if you think this pic is hot or not!",
                      username, likesString];
    
    [self refresh];    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
