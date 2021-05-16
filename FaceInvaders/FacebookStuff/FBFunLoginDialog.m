//
//  FBFunLoginDialog.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/8/12.
//  Credit to Ray Wenderlich Tutorials
//

#import "FBFunLoginDialog.h"

@interface FBFunLoginDialog ()

@end

@implementation FBFunLoginDialog
@synthesize webView = _webView;
@synthesize apiKey = _apiKey;
@synthesize requestedPermissions = _requestedPermissions;
@synthesize delegate = _delegate;

- (id)initWithAppId:(NSString *)apiKey requestedPermissions:(NSString *)requestedPermissions delegate:(id<FBFunLoginDialogDelegate>)delegate {
    if ((self = [super initWithNibName:@"FBFunLoginDialog"
                                bundle:[NSBundle mainBundle]])) {
        self.apiKey = apiKey;
        self.requestedPermissions = requestedPermissions;
        self.delegate = delegate;
        
        webViewLoadedOnce = NO;
    }
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.apiKey = nil;
    self.requestedPermissions = nil;
    [super dealloc];
}
- (void)login {
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    NSString *redirectUrlString =
    @"http://www.facebook.com/connect/login_success.html/";
    NSString *authFormatString =
    @"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch/";
    
    NSString *urlString = [NSString stringWithFormat:authFormatString,
                           _apiKey, redirectUrlString, _requestedPermissions]; //, @"/"
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"NSURL: %@", urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(void)logout {
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"\n\nshouldStartLoadWithRequest called\n\n");
    
    _urlString = request.URL.absoluteString;
    
    if (webView.isLoading) {
        NSLog(@"shoudl start load returned no");
        return YES;
    }else{
        [self checkForAccessToken:_urlString];
        [self checkLoginRequired:_urlString];
        return TRUE;
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"\n\nwebViewDidFinishLoad called\n");
    //if (!webViewLoadedOnce) {
        //[self checkForAccessToken:_urlString];
        //[self checkLoginRequired:_urlString];
     //   webViewLoadedOnce = YES;
    //}else{
        //do nothing (webview is loading twice for some fucking reason)
    //}
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFail: %@; stillLoading:%@", [[webView request]URL],
          (webView.loading?@"NO":@"YES"));
}
-(void)checkForAccessToken:(NSString *)urlString {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"client_id=(.*)&" //access_token
                                  options:0 error:&error];
    NSLog(@"regex = \n%@\n", regex);
    if (regex != nil) {
        NSTextCheckingResult *firstMatch =
        [regex firstMatchInString:urlString
                          options:0 range:NSMakeRange(0, [urlString length])];
        if (firstMatch) {
            NSLog(@"first match found (access token)\n");
            NSRange accessTokenRange = [firstMatch rangeAtIndex:1];
            NSString *accessToken = [urlString substringWithRange:accessTokenRange];
            accessToken = [accessToken
                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //accessToken = [NSString stringWithFormat:@"%@/",accessToken];
            NSLog(@"\n\naccessToken = \n%@\n", accessToken);
            [_delegate accessTokenFound:accessToken];
        }
    }
}
-(void)checkLoginRequired:(NSString *)urlString {
    NSLog(@"Url: %@",urlString);
    
    /*
    if ([urlString rangeOfString:@"login.php"].location != NSNotFound) {
        [_delegate displayRequired];
        NSLog(@"display required");
    }
     */
    
    NSLog(@"Url: %@",urlString);
    if ([urlString rangeOfString:@"login.php"].location != NSNotFound && [urlString rangeOfString:@"refid"].location == NSNotFound) {
        [_delegate displayRequired];
        NSLog(@"display required");
    } else if ([urlString rangeOfString:@"user_denied"].location != NSNotFound) {
        [_delegate closeTapped];
        NSLog(@"user denied");
    }
    
}

- (IBAction)closeTapped:(id)sender {
    [_delegate closeTapped];
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
