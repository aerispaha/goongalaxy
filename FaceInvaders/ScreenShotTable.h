//
//  ScreenShotTable.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 10/23/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "ImageProcessor.h"
#import "Facebook.h"
#import "ScreenshotHandler.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface ScreenShotTable : UITableView <UITableViewDataSource, UITableViewDelegate, FBRequestDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIActivityItemSource, MFMailComposeViewControllerDelegate> {
    AppDelegate *appDelegate;
    NSMutableArray *screenShotArray;
    NSMutableArray *screenshotPaths;
    Facebook *fb;
    int picIndexPath;

    float tableScale;
    
    NSString *_message;

}

- (id)initWithMessage:(NSString *)message;

@property (nonatomic, retain) UITableView *table;
@end
