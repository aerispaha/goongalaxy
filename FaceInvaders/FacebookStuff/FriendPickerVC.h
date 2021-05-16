//
//  FriendPickerVC.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/15/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "cocos2d.h"

@interface FriendPickerVC : UIViewController<FBFriendPickerDelegate>

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end
