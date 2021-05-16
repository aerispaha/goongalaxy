//
//  CollisionAssistant.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 11/8/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Monster.h"

@interface CollisionAssistant : NSObject{
    
}

+ (BOOL)detectCollisionBetweenSprite:(CCSprite *) s1 andSprite:(CCSprite *)s2;
+ (BOOL)detectCollisionInWorldSpaceBetweenChild:(CCSprite *) s1 andWorldSprt:(CCSprite *)s2;



@end
