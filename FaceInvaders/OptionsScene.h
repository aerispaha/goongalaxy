//
//  OptionsScene.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/30/12.
//  Copyright 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "HelloWorldLayer.h"
#import "IntroScene.h"

@interface OptionsScene :  CCLayerColor {
    AppDelegate *appDelegate;
    CCMenu *optionsMenu;
    CGSize winSize;
}
+(CCScene *) scene;

@end
