//
//  LoadingScene.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/29/12.
//  Copyright 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"
#import "AppDelegate.h"

@interface LoadingScene : CCLayerColor {
    AppDelegate *appDelegate;
}
+(CCScene *) scene;
@end
