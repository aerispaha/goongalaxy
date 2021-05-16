//
//  CameraScene.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/20/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "cocos2d.h"

@interface CameraLayer :  CCLayerColor <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

    UIImagePickerController *camera;
    AppDelegate *appDelegate;
    UIImage *camImage;
}

@end

@interface CameraScene : CCScene {
    CameraScene *_layer;
}
@property (nonatomic, retain) CameraScene *layer;
@end