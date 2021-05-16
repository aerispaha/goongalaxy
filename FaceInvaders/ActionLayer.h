//
//  ActionLayer.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 5/31/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "drawSpace.h"
#import "cpMouse.h"
#import "CPSprite.h"


@interface ActionLayer : CCLayer {
    cpSpace *space;
    cpMouse *mouse;
    
    CPSprite *cat;
}

+ (id)scene;

@end