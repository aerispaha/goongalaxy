//
//  CPSprite.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 6/1/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"


@interface CPSprite : CCSprite {
    cpBody *body;
    cpShape *shape;
    cpSpace *space;
    CCParticleSun *emitter;
    //CCSprite *face;
    //BOOL hasFace;
    BOOL canBeDestroyed;
    
}

@property (assign) cpBody *body;
//@property (assign) CCParticleSun *emitter;
//@property (assign) CCSprite *face;


- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location spriteFrameName:(NSString *)spriteFrameName;
- (id)initWithSpace:(cpSpace *)theSpace withImageName:(NSString *)imageName;
- (id)initWithSpace:(cpSpace *)theSpace withRectImageNamed:(NSString *)imageName;
- (void)update;
- (void)updateChipBody;
- (void)createRectBodyInSpace:(cpSpace *)theSpace;
- (void)createRectBodyAtLocation:(CGPoint)location inSpace:(cpSpace *)theSpace;
- (void)createRectBodyAtLocation:(CGPoint)location withMass:(int)mass inSpace:(cpSpace *)theSpace;
- (void)createPolygonBodyAtLocation:(CGPoint)location withScale:(float)scale inSpace:(cpSpace *)theSpace;
- (void)createPolygonBodyInSpace:(cpSpace *)theSpace withScale:(float )scale;
- (void)destroy;
- (void)destroyBodyinSpace:(cpSpace *)theSpace;

//movements
//- (id)randomBezierToPoint:(CGPoint)pos;
@end