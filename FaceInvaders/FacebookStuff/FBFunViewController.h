//
//  FBFunViewController.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/8/12.
//  Credit to Ray Wenderlich Tutorials
//

#import <UIKit/UIKit.h>
#import "FBFunLoginDialog.h"

typedef enum {
    LoginStateStartup,
    LoginStateLoggingIn,
    LoginStateLoggedIn,
    LoginStateLoggedOut
} LoginState;

@interface FBFunViewController : UIViewController <FBFunLoginDialogDelegate> {
    UILabel *_loginStatusLabel;
    UIButton *_loginButton;
    LoginState _loginState;
    FBFunLoginDialog *_loginDialog;
    UIView *_loginDialogView;
    
    //part 2 wenderlich
    UITextView *_textView;
    UIImageView *_imageView;
    UISegmentedControl *_segControl;
    UIWebView *_webView;
    NSString *_accessToken;
}

@property (retain) IBOutlet UILabel *loginStatusLabel;
@property (retain) IBOutlet UIButton *loginButton;
@property (retain) FBFunLoginDialog *loginDialog;
@property (retain) IBOutlet UIView *loginDialogView;

@property (retain) IBOutlet UITextView *textView;
@property (retain) IBOutlet UIImageView *imageView;
@property (retain) IBOutlet UISegmentedControl *segControl;
@property (retain) IBOutlet UIWebView *webView;
@property (copy) NSString *accessToken;

- (IBAction)rateTapped:(id)sender;

- (IBAction)loginButtonTapped:(id)sender;

@end