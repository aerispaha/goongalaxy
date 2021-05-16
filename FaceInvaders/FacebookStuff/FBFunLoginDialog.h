//
//  FBFunLoginDialog.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/8/12.
//  Credit to Ray Wenderlich Tutorials
//

#import <UIKit/UIKit.h>

@protocol FBFunLoginDialogDelegate
- (void)accessTokenFound:(NSString *)accessToken;
- (void)displayRequired;
- (void)closeTapped;
@end

@interface FBFunLoginDialog : UIViewController <UIWebViewDelegate> {
    UIWebView *_webView;
    NSString *_apiKey;
    NSString *_requestedPermissions;
    NSString *_urlString;
    id <FBFunLoginDialogDelegate> _delegate;
    
    BOOL webViewLoadedOnce;
}

@property (retain) IBOutlet UIWebView *webView;
@property (copy) NSString *apiKey;
@property (copy) NSString *requestedPermissions;
@property (assign) id <FBFunLoginDialogDelegate> delegate;

- (id)initWithAppId:(NSString *)apiKey
requestedPermissions:(NSString *)requestedPermissions
           delegate:(id<FBFunLoginDialogDelegate>)delegate;
- (IBAction)closeTapped:(id)sender;
- (void)login;
- (void)logout;

-(void)checkForAccessToken:(NSString *)urlString;
-(void)checkLoginRequired:(NSString *)urlString;

@end