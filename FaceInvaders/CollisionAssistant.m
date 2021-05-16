//
//  CollisionAssistant.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 11/8/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "CollisionAssistant.h"

@implementation CollisionAssistant

+ (BOOL)detectCollisionBetweenSprite:(CCSprite *)s1 andSprite:(CCSprite *)s2{
    
    //conver s1 to current scene frame of reference
    //HelloWorldLayer *layer = (HelloWorldLayer *)s2.parent;
    //CGPoint pos = [s2 convertToWorldSpace:s1.position];
    
    
    CGRect s1Rect = CGRectMake(s1.position.x - (s1.boundingBox.size.width/2),
                               s1.position.y - (s1.boundingBox.size.height/2),
                               s1.boundingBox.size.width,
                               s1.boundingBox.size.height);
    
    CGRect s2Rect = CGRectMake(
                               s2.position.x - (s2.boundingBox.size.width/2),
                               s2.position.y - (s2.boundingBox.size.height/2),
                               s2.boundingBox.size.width,
                               s2.boundingBox.size.height);
    
    //CHECK FOR AN INTERSECTION BETWEEN EACH PROJECTILE AND EACH TARGET
    return CGRectIntersectsRect(s1Rect, s2Rect);
}

+ (BOOL)detectCollisionInWorldSpaceBetweenChild:(CCSprite *)s1 andWorldSprt:(CCSprite *)s2{
    
    CGRect s1Rect = CGRectMake(s1.position.x - (s1.boundingBox.size.width/2),
                               s1.position.y - (s1.boundingBox.size.height/2),
                               s1.boundingBox.size.width,
                               s1.boundingBox.size.height);
    CGPoint nodeSOrigin = ccp(s1.position.x-s1.boundingBox.size.width/2, s1.position.y-s1.boundingBox.size.height/2);
    NSLog(@"s1Rect node S origin: (%.f, %.f)",nodeSOrigin.x, nodeSOrigin.y);
    s1Rect.origin = [s2 convertToWorldSpace:nodeSOrigin];
    NSLog(@"s1Rect world S origin: (%.f, %.f)",s1Rect.origin.x, s1Rect.origin.y);
    
    CGRect s2Rect = CGRectMake(
                               s2.position.x - (s2.boundingBox.size.width/2),
                               s2.position.y - (s2.boundingBox.size.height/2),
                               s2.boundingBox.size.width,
                               s2.boundingBox.size.height);
    
    //CHECK FOR AN INTERSECTION BETWEEN EACH PROJECTILE AND EACH TARGET
    return CGRectIntersectsRect(s1Rect, s2Rect);
}
@end
