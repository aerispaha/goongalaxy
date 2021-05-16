//
//  ActionLayer.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 5/31/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//


//Adapted from  Wenderlich tutorial
#import "ActionLayer.h"

@implementation ActionLayer

+ (id)scene {
    CCScene *scene = [CCScene node];
    ActionLayer *layer = [ActionLayer node];
    [scene addChild:layer];
    return scene;
}
- (void)createSpace {
    space = cpSpaceNew();
    space->gravity = ccp(0, -750);
    //optimazation controlling at what resolution physics math is performed
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
}
- (void)createGround {    
    // 1
    CGSize winSize = [[CCDirector sharedDirector] winSize]; 
    CGPoint lowerLeft = ccp(0, 0);
    CGPoint lowerRight = ccp(winSize.width, 0);
    
    // 2
    cpBody *groundBody = cpBodyNewStatic();
    
    
    // 3
    float radius = 10.0;
    cpShape *groundShape = cpSegmentShapeNew(groundBody, lowerLeft, lowerRight, radius);
    
    
    // 4
    groundShape->e = 1.0; // elasticity
    groundShape->u = 1.0; // friction 
    
    // 5
    cpSpaceAddShape(space, groundShape);    
}
// Add new method
- (void)createBoxAtLocation:(CGPoint)location {
    
    float boxSize = 60.0;
    float mass = 1.0;
    cpBody *body = cpBodyNew(mass, cpMomentForBox(mass, boxSize, boxSize));
    body->p = location;
    cpSpaceAddBody(space, body);
    
    cpShape *shape = cpBoxShapeNew(body, boxSize, boxSize);
    shape->e = 1.0; 
    shape->u = 1.0;
    cpSpaceAddShape(space, shape);
    
}
- (void)createBodyAtLocation:(CGPoint)location {
    
    // Add your vertices from Vertex Helper here
    int num = 4;
    CGPoint verts[] = {
        cpv(-31.5f, 69.5f),
        cpv(41.5f, 66.5f),
        cpv(40.5f, -69.5f),
        cpv(-55.5f, -70.5f)
    };
    
    float mass = 1.0;
    float moment = cpMomentForPoly(mass, num, verts, CGPointZero);
    cpBody *body = cpBodyNew(mass, moment);
    body->p = location;
    cpSpaceAddBody(space, body);
    
    cpShape *shape = cpPolyShapeNew(body, num, verts, CGPointZero);
    shape->e = 0.3; 
    shape->u = 0.5;
    cpSpaceAddShape(space, shape);
    
}

- (void)draw {
    
    drawSpaceOptions options = {
        0, // drawHash
        0, // drawBBs,
        1, // drawShapes
        4.0, // collisionPointSize
        4.0, // bodyPointSize,
        2.0 // lineThickness
    };
    
    drawSpace(space, &options);
    
}
- (void)update:(ccTime)dt {
    cpSpaceStep(space, dt);
    [cat update];
}
- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    cpMouseGrab(mouse, touchLocation, false);
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    cpMouseMove(mouse, touchLocation);

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    cpMouseRelease(mouse);
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    cpMouseRelease(mouse);    
}

- (void)dealloc {
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [super dealloc];
}
- (id)init {
    if ((self = [super init])) {        
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self createSpace];
        [self createGround];
        /*
        [self createBoxAtLocation:ccp(100,100)];
        [self createBoxAtLocation:ccp(200,200)];
        */
        [self scheduleUpdate];
        
        mouse = cpMouseNew(space);
        self.isTouchEnabled = YES;
        
        cat = [[CPSprite alloc] initWithSpace:space location:ccp(245, 217) spriteFrameName:@"Monster1.png"];
        [self addChild:cat];
        
        
        
        
    }
    return self;
}  

@end