//
//  CPSprite.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 6/1/12. (really by Ray Wenderlich)
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "CPSprite.h"

@implementation CPSprite
@synthesize body;
//@synthesize emitter;
#define ARC4RANDOM_MAX      0x100000000


- (void)update {    
    
    self.position = body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-1 * body->a);
    
}
- (void)updateChipBody {
    
    body->p = self.position;
    body->a = -CC_DEGREES_TO_RADIANS(self.rotation);
    
}
- (void)createRectBodyInSpace:(cpSpace *)theSpace {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float mass = 1.0;
    body = cpBodyNew(mass, cpMomentForBox(mass, self.contentSize.width, self.contentSize.height));
    body->p = ccp(winSize.width + 300, winSize.height/2); //location;
    body->data = self;
    cpSpaceAddBody(theSpace, body);

    shape = cpBoxShapeNew(body, self.contentSize.width, self.contentSize.height);
    shape->e = 0.3; 
    shape->u = 1.0;
    shape->data = self;
    cpSpaceAddShape(theSpace, shape);
}

- (void)createRectBodyAtLocation:(CGPoint)location inSpace:(cpSpace *)theSpace{
    float mass = 1.0;
    body = cpBodyNew(mass, cpMomentForBox(mass, self.boundingBox.size.width, self.boundingBox.size.height));
    body->p = location; //location;
    body->data = self;
    cpSpaceAddBody(theSpace, body);
    
    shape = cpBoxShapeNew(body, self.boundingBox.size.width, self.boundingBox.size.height);
    shape->e = 0.3;
    shape->u = 1.0;
    shape->data = self;
    cpSpaceAddShape(theSpace, shape);
    canBeDestroyed = YES;
}
- (void)createRectBodyAtLocation:(CGPoint)location withMass:(int)mass inSpace:(cpSpace *)theSpace{
    
    body = cpBodyNew(mass, cpMomentForBox(mass, self.boundingBox.size.width, self.boundingBox.size.height));
    body->p = location; //location;
    body->data = self;
    cpSpaceAddBody(theSpace, body);
    
    shape = cpBoxShapeNew(body, self.boundingBox.size.width, self.boundingBox.size.height);
    shape->e = 0.3;
    shape->u = 1.0;
    shape->data = self;
    cpSpaceAddShape(theSpace, shape);
    canBeDestroyed = YES;
}
- (void)createPolygonBodyAtLocation:(CGPoint)location withScale:(float)scale inSpace:(cpSpace *)theSpace{
    // Add your vertices from Vertex Helper here
    int num = 7;
    CGPoint verts[] = {
        cpv(-4.0f*scale, 230.0f*scale),
        cpv(168.0f*scale, 144.0f*scale),
        cpv(184.0f*scale, 8.0f*scale),
        cpv(152.0f*scale, -142.0f*scale),
        cpv(-164.0f*scale, -144.0f*scale),
        cpv(-206.0f*scale, 34.0f*scale),
        cpv(-156.0f*scale, 190.0f*scale)
    };
         
    float mass = 1.0;
    float moment = cpMomentForPoly(mass, num, verts, CGPointZero);
    body = cpBodyNew(mass, moment);
    body->p = location;
    cpSpaceAddBody(theSpace, body);
    
    shape = cpPolyShapeNew(body, num, verts, CGPointZero);
    shape->e = 0.3; 
    shape->u = 0.5;
    cpSpaceAddShape(theSpace, shape);
}

- (void)createPolygonBodyInSpace:(cpSpace *)theSpace withScale:(float)scale{
    // Add your vertices from Vertex Helper here
    int num = 7;
    CGPoint verts[] = {
        cpv(-4.0f*scale, 230.0f*scale),
        cpv(168.0f*scale, 144.0f*scale),
        cpv(184.0f*scale, 8.0f*scale),
        cpv(152.0f*scale, -142.0f*scale),
        cpv(-164.0f*scale, -144.0f*scale),
        cpv(-206.0f*scale, 34.0f*scale),
        cpv(-156.0f*scale, 190.0f*scale)
    };
    
    float mass = 2;
    float moment = cpMomentForPoly(mass, num, verts, CGPointZero);

    body = cpBodyNew(mass, moment);
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    body->p = ccp(winSize.width/2, winSize.height/2); //location;
    cpSpaceAddBody(theSpace, body);
    
    shape = cpPolyShapeNew(body, num, verts, CGPointZero);

    shape->e = 0.3; 
    shape->u = 0.5;
    cpSpaceAddShape(theSpace, shape);
    
}
- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location spriteFrameName:(NSString *)spriteFrameName {
    
    if ((self = [super initWithFile:spriteFrameName])) { //Ray used initWithSpriteFrameName (I think for sprite sheets?)
        
        space = theSpace;
        //[self createBodyAtLocation:location];
        [self createPolygonBodyAtLocation:location withScale:1 inSpace:theSpace];
        canBeDestroyed = YES;
        
    }
    return self;
    
}
-(id)initWithSpace:(cpSpace *)theSpace withImageName:(NSString *)imageName{
    
    if ((self = [super initWithFile:imageName])) { //Ray used initWithSpriteFrameName (I think for sprite sheets?)
    
        //[self createBodyAtLocation:location];
        [self createPolygonBodyInSpace:theSpace withScale:1];
        canBeDestroyed = YES;
    }
    return self;
}
-(id)initWithSpace:(cpSpace *)theSpace withRectImageNamed:(NSString *)imageName{
    
    if ((self = [super initWithFile:imageName])) { //Ray used initWithSpriteFrameName (I think for sprite sheets?)
        
        space = theSpace;
        //[self createBodyAtLocation:location];
        [self createRectBodyInSpace:space];
        canBeDestroyed = YES;
    }
    return self;
}
- (void)destroy {
    
    if (!canBeDestroyed) return;
    
    cpSpaceRemoveBody(space, body);
    cpSpaceRemoveShape(space, shape);
    [self removeFromParentAndCleanup:YES];
    /*
    if (self.emitter != nil) {
        [self removeChild:self.emitter  cleanup:YES];
        NSLog(@"emitter removed!");
    }
    */
}
- (void)destroyBodyinSpace:(cpSpace *)theSpace{
    cpSpaceRemoveBody(theSpace, self.body);
    cpSpaceRemoveShape(theSpace, self.body->shapesList);
    [self removeFromParentAndCleanup:YES];
}


@end