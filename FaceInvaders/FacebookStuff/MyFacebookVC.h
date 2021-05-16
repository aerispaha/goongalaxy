//
//  MyFacebookVC.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/14/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "cocos2d.h"

@interface MyFacebookVC : UIViewController <FBSessionDelegate>{
    Facebook *facebook;
    FBProfilePictureView *profilePic;
    FBFriendPickerViewController *friendPicker;
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) FBProfilePictureView *profilePic;
@property (nonatomic, retain) FBFriendPickerViewController *friendPicker;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@end
