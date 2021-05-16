//
//  Background.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/21/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "Terrain.h"

@interface Background : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
    Terrain * _terrain2;
}

+ (CCScene *)scene;
+ (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize;
+ (ccColor4F)randomBrightColor;
+ (ccColor3B)randomBrightColor3B;
+ (ccColor3B)randomMatchingColor3BToColor:(ccColor3B)col;
+ (ccColor3B)randomDullColor3B;
    
@end