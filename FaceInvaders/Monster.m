//
//  Monster.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 4/20/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "Monster.h"
#import "ImageProcessor.h"

// ======================================================================================== //
// ======================================================================================== //
@implementation Monster
@synthesize hp = _curHp;
@synthesize hpMax;
@synthesize minMoveDuration = _minMoveDuration;
@synthesize maxMoveDuration = _maxMoveDuration;
@synthesize path;
@synthesize isBoss;
@synthesize hasFace;
@synthesize hasCustomPath;
@synthesize hasChipmunkBody;
@synthesize isSpecialSequence;
@synthesize isPartOfASynchGroup;
@synthesize canCollideWithPlayer;
@synthesize mustShootEyes;
@synthesize mustShootFace;
@synthesize isFlickering;
@synthesize faceOffset;
@synthesize face;
@synthesize monsterBody;
@synthesize fbFriendName;
@synthesize type;
@synthesize leftEyePos;
@synthesize rightEyePos;
@synthesize mouthPos;
@synthesize bodyPartSprites;
@synthesize appendages;

#define ARC4RANDOM_MAX      0x100000000
#define BULLET_TYPE 1
#define MONSTER_TYPE 2

+ (NSMutableArray *)arrayOfActiveFaceSprites{ //not used (12/12/12)
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease]; //MEMORY FUCKS, previously wasn't autoreleased
    NSLog(@"activeFaceArray called");
    //FaceData *fdObj;
    //fdObj = [[FaceData alloc] init];
    
    for (FaceData *fdObj/*fdObj*/ in appDelegate.faceDataArray) {
        
        if ([fdObj.isActive intValue] == 1) {
            
            CCTexture2D *tex = [[[CCTexture2D alloc] initWithImage:fdObj.faceCropped] autorelease];
            Face *faceSprite = [Face spriteWithTexture:tex];
            faceSprite.fbFriendName = fdObj.name; //retain name of face for access during game
            
            [array addObject:faceSprite];
        }
    }
    NSLog(@"activeFaceArray count: %d", [array count]);
    
    //[fdObj release];
    
    return array;
}
- (CGPoint)randomPositionOfNewPart:(CCSprite *)newPart inBasePart:(CCSprite *)base{
    CGPoint pos;
    
    int i = arc4random() % 4;
    if (i == 0) {
        //at bottom
        pos = ccp((arc4random() % (int)base.contentSize.width), -0.5*newPart.contentSize.height/2);
    }else if (i == 1){
        //at top
        pos = ccp((arc4random() % (int)base.contentSize.width), base.contentSize.height + 0.5*newPart.contentSize.height/2);
    }else if (i == 2){
        //at right edge
        pos = ccp(base.contentSize.width + 0.5*newPart.contentSize.width/2, (arc4random() % (int)base.contentSize.height));
    }else if (i == 3){
        //at left edge
        pos = ccp(-0.5*newPart.contentSize.width/2, (arc4random() % (int)base.contentSize.height));
    }
    return pos;
}
- (CGPoint)randomSnakedPositionOfNewPart:(CCSprite *)newPart inBasePart:(CCSprite *)base{
    //place newsprite at location along the right edge of preceding sprite
    //should result in a snaking chain of sprites
    CGPoint pos = ccp(base.contentSize.width + 0.5*newPart.contentSize.width/2, (arc4random() % (int)base.contentSize.height));
    return pos;
}

//accent movements for monster with an array of children
- (void)makePartsHaveAwkwardJiggle:(NSArray *)array{
    //rotate parts about their anchor points
    for (CCSprite *part in array) {
        float angle = arc4random() % (20);
        if ((arc4random() % 2)==0) {
            angle = angle*-1;
        }
        //NSLog(@"angle %.f", angle);
        CCRotateTo * rotate = [CCEaseElasticIn actionWithAction:[CCRotateBy actionWithDuration:0.75 angle:angle]];
        CCRotateTo * rotBack = [CCEaseElasticOut actionWithAction:[CCRotateBy actionWithDuration:0.75 angle:-angle]];
        [part runAction:[CCRepeatForever actionWithAction:[CCSequence actions:rotate, rotBack, nil]]];
    }
}
- (void)makePartHaveAwkwardJiggle{
    float angle = arc4random() % (90);
    CCRotateTo * rotate = [CCEaseElasticIn actionWithAction:[CCRotateBy actionWithDuration:0.75 angle:angle]];
    CCRotateTo * rotBack = [CCEaseElasticOut actionWithAction:[CCRotateBy actionWithDuration:0.75 angle:-angle]];
    [self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:rotate, rotBack, nil]]];
}
- (void)makePartsEaseBacknForth:(NSArray *)array{

    float angle = arc4random() % (30) + 10;
    int j = 0;//alternate every 4 pieces to create "slither" look?
    for (CCSprite *part in array) {
        
        j++;
        if (j==4) {
            angle = -angle;
            j=0;
        }
            
        //NSLog(@"angle %.f", angle);
        CCRotateTo * rotateRt = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:0.75 angle:angle] rate:2];//rate was 1
        CCRotateTo * rotRtFin = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:0.75 angle:-angle] rate:2]; //1
        [part runAction:[CCRepeatForever actionWithAction:[CCSequence actions:rotateRt, rotRtFin, nil]]];
    }
}
- (void)makeSpriteJiggle{
    CCSprite *sp = self;
    [sp runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
    CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-8.0];
    CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
    CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:8.0];
    CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
    [sp runAction:[CCRepeatForever actionWithAction:rotSeq]];
}
- (void)makeSpriteJiggleOnce{
    CCSprite *sp = self;
    [sp runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
    CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-8.0];
    CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
    CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:8.0];
    CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
    [sp runAction:rotSeq];
}
- (void)makeSpriteSway{
    CCSprite *sp = self;
    float duration = 0.7;
    [sp runAction:[CCRotateTo actionWithDuration:duration angle:0]];
    CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:duration angle:-8.0];
    CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:duration angle:0.0];
    CCRotateTo * rotRight = [CCRotateBy actionWithDuration:duration angle:8.0];
    CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
    [sp runAction:[CCRepeatForever actionWithAction:rotSeq]];
}

//positioning utilities
- (void)positionMonsterOffRightScreen{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = self.contentSize.height/2;
    int maxY = winSize.height - self.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.position = ccp(winSize.width + (self.contentSize.width/2), actualY);
}
- (void)positionMonsterOffBottomScreen{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = self.contentSize.width/2;
    int maxX = winSize.width - self.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.position = ccp(actualX,  -(self.contentSize.height/2));
}
- (CGPoint)randPositionOffRightScreen{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = self.contentSize.height/2;
    int maxY = winSize.height - self.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    return ccp(winSize.width + (self.contentSize.width/2), actualY);
}
+ (CGPoint)randPositionOffRightScreen:(CCSprite *)sprite{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = sprite.contentSize.height/2;
    int maxY = winSize.height - sprite.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    return ccp(winSize.width + (sprite.contentSize.width/2), actualY);
}
+ (CGPoint)randPositionOnScreen{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    double val1 = ((double)arc4random() / ARC4RANDOM_MAX);
    double val2 = ((double)arc4random() / ARC4RANDOM_MAX);

    return ccp(winSize.width*val1, winSize.height*val2);
}
//on screen paths
- (CCMoveTo *)moveCrossScreen{
    //USED FOR MOVING "SPRTIES", NOT CIPMUNK BODIES.
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = self.contentSize.height/2;
    int maxY = winSize.height - self.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    int actualYdestination = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.position = ccp(winSize.width + (self.contentSize.width/2), actualY);
    
    //add to mutable array of targets
    self.tag = 1;
    
    // Determine speed of the target
    int minDuration = self.minMoveDuration;
    int maxDuration = self.maxMoveDuration;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the action
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-self.contentSize.width/2, actualYdestination)];
    return actionMove;
}
- (CCMoveTo *)moveToRandomPlaceOnRightOfScreenWithDuration:(float)duration{

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Determine where to send monster along the Y axis
    int minY = self.contentSize.height/2;
    int maxY = winSize.height - self.contentSize.height/2;
    int rangeY = maxY - minY;
    int destinationY = (arc4random() % rangeY) + minY;
    
    // Determine where to send monster along the X axis
    int minX = winSize.width*0.5;
    int maxX = winSize.width - self.contentSize.width/2;
    int rangeX = maxX - minX;
    int destinationX = (arc4random() % rangeX) + minX;
    
    //add to mutable array of targets
    self.tag = 1;
    
    // Determine speed of the target
    int minDuration;
    int maxDuration;
    if (duration == 0) {
        minDuration = self.minMoveDuration;
        maxDuration = self.maxMoveDuration;
    }else{
        minDuration = duration;
        maxDuration = duration;
    }
    
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the action
    CCMoveTo *actionMove = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:actualDuration position:ccp(destinationX, destinationY)]rate:2];
    return actionMove;
}
- (id)randomMovesOnScreen{
    NSMutableArray *actionArray = [[[NSMutableArray alloc] init] autorelease];
    int numberOfActions = 5;
    for (int i = 0; i<numberOfActions; i++) {
        [actionArray addObject:[CCEaseInOut actionWithAction:[self moveToRandomPlaceOnRightOfScreenWithDuration:0] rate:2]];
    }
    
    return [CCSequence actionsWithArray:actionArray];
}
- (void)giveRandomMovesOnScreen{
    NSMutableArray *actionArray = [[[NSMutableArray alloc] init] autorelease];
    int numberOfActions = 5;
    for (int i = 0; i<numberOfActions; i++) {
        [actionArray addObject:[CCEaseInOut actionWithAction:[self moveToRandomPlaceOnRightOfScreenWithDuration:0] rate:2]];
    }
    
    [self runAction:[CCRepeatForever actionWithAction:[CCSequence actionsWithArray:actionArray]]];
}
- (void)giveRandomMovesWithDuration:(float)duration{
    NSMutableArray *actionArray = [[[NSMutableArray alloc] init] autorelease];
    int numberOfActions = 5;
    for (int i = 0; i<numberOfActions; i++) {
        [actionArray addObject:[CCEaseInOut actionWithAction:[self moveToRandomPlaceOnRightOfScreenWithDuration:duration] rate:2]];
    }
    
    [self runAction:[CCRepeatForever actionWithAction:[CCSequence actionsWithArray:actionArray]]];
}
+ (NSArray *)arrayOfSameBeziers:(int)numberOfBeziers toPoint:(CGPoint)pos{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    NSMutableArray *beziers = [[[NSMutableArray alloc] init] autorelease]; //MEMORY FUCKS, previously wasn't autoreleased
    
    //set the constants for all the beziers
    double val1 = ((double)arc4random() / ARC4RANDOM_MAX);
    double val2 = ((double)arc4random() / ARC4RANDOM_MAX);
    double val3 = ((double)arc4random() / ARC4RANDOM_MAX);
    double val4 = ((double)arc4random() / ARC4RANDOM_MAX);
    
    //NSLog(@"cntrlPt1: (%.2f, %.2f) \nctrlPt2:(%.2f, %.2f)", val1, val2, val3, val4);
    CGPoint cntrlPt1 = ccp(winSize.width*val1, winSize.height*val2);
    CGPoint cntrlPt2 = ccp(winSize.width*val3, winSize.height*val4);
    
    //create the copied beziers. these cant be resused apparently, so we make copies
    for (int i = 0; i <= numberOfBeziers; i++) {
        ccBezierConfig bezier;
        
        bezier.controlPoint_1 = cntrlPt1;
        bezier.controlPoint_2 = cntrlPt2;
        bezier.endPosition = pos;
        
        id bezierAction = [CCEaseInOut actionWithAction:[CCBezierTo actionWithDuration:3 bezier:bezier] rate:2];
        
        [beziers addObject:bezierAction];
    }
    return beziers;
}
+ (NSArray *)arrayOfDifferentBeziers:(int)numberOfBeziersOnScreen{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    NSMutableArray *beziers = [[[NSMutableArray alloc] init] autorelease]; //MEMORY FUCKS, previously wasn't autoreleased
    //create the copied beziers. these cant be resused apparently, so we make copies
    for (int i = 0; i <= numberOfBeziersOnScreen; i++) {
        
        //set the constants for all the beziers
        double val1 = ((double)arc4random() / ARC4RANDOM_MAX);
        double val2 = ((double)arc4random() / ARC4RANDOM_MAX);
        double val3 = ((double)arc4random() / ARC4RANDOM_MAX);
        double val4 = ((double)arc4random() / ARC4RANDOM_MAX);
        double val5 = ((double)arc4random() / ARC4RANDOM_MAX);
        double val6 = ((double)arc4random() / ARC4RANDOM_MAX);
        
        //NSLog(@"cntrlPt1: (%.2f, %.2f) \nctrlPt2:(%.2f, %.2f)", val1, val2, val3, val4);
        CGPoint cntrlPt1 = ccp(winSize.width*val1, winSize.height*val2);
        CGPoint cntrlPt2 = ccp(winSize.width*val3, winSize.height*val4);
        CGPoint endPos = ccp(winSize.width*val5, winSize.height*val6);
        
        
        ccBezierConfig bezier;
        
        bezier.controlPoint_1 = cntrlPt1;
        bezier.controlPoint_2 = cntrlPt2;
        bezier.endPosition = endPos;
        
        id bezierAction = [CCEaseInOut actionWithAction:[CCBezierTo actionWithDuration:3 bezier:bezier] rate:2];
        
        [beziers addObject:bezierAction];
    }
    return beziers;
}

//accents to aliens
- (void)giveSpiralEyes{
    
    self.leftEye =  [CCSprite spriteWithFile:@"spiral.png"];//[[CCSprite alloc] initWithFile:@"spiral.png"];
    self.rightEye = [CCSprite spriteWithFile:@"spiral.png"];//[[CCSprite alloc] initWithFile:@"spiral.png"];
    
    [self.leftEye runAction: [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.2 angle:60]]];
    [self.rightEye runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.2 angle:60]]];
    
    //self.leftEye = lEye;
    [self addChild:self.leftEye];
    self.leftEye.position = self.leftEyePos;
    
    //alien.rightEye = rEye;
    [self addChild:self.rightEye];
    self.rightEye.position = self.rightEyePos;
}
- (void)giveRedEyes{
    self.leftEye = [CCSprite spriteWithFile:@"plasma.png"];//[[CCSprite alloc] initWithFile:@"plasma.png"];
    self.rightEye = [CCSprite spriteWithFile:@"plasma.png"];//[[CCSprite alloc] initWithFile:@"plasma.png"];
    
    self.leftEye.color = ccc3(255, 0, 0);
    self.rightEye.color = ccc3(255, 0, 0);
    
    //self.leftEye = lEye;
    [self addChild:self.leftEye];
    self.leftEye.position = self.leftEyePos;
    
    //alien.rightEye = rEye;
    [self addChild:self.rightEye];
    self.rightEye.position = self.rightEyePos;
}
- (void)makeEyesFadeOut{
    [self.leftEye runAction:[CCFadeOut actionWithDuration:0.1]];
    [self.rightEye runAction:[CCFadeOut actionWithDuration:0.1]];
}
- (void)makeFlicker{
    
    id flickerDown = [CCFadeTo actionWithDuration:0.01 opacity:150];
    id flickerUp = [CCFadeTo actionWithDuration:0.01 opacity:255];
    id delay = [CCDelayTime actionWithDuration:0.05];
    id flicker = [CCSequence actions:flickerDown, delay, flickerUp, delay, nil];
    id endFlicker = [CCCallFunc actionWithTarget:self selector:@selector(stopFlciker:)];
    [self runAction:[CCSequence actions:[CCRepeat actionWithAction:flicker times:5], endFlicker, nil]];
    
    self.isFlickering = YES;
}
- (void)stopFlciker:(id)sender{
    self.isFlickering = NO;
}
//chipmunk stuff
- (void)addChipmunkBody:(int)j inSpace:(cpSpace *)theSpace{
    float mass = 1.0;
    float moment;
    
    if (j==0) {
        int numVerts = 6;
        float s = 0.5;
        CGPoint verts[] = {
            cpv(-171.8f*s, -0.7f*s),
            cpv(-81.3f*s, 200.1f*s),
            cpv(70.0f*s, 202.9f*s),
            cpv(181.7f*s, -0.7f*s),
            cpv(120.9f*s, -188.8f*s),
            cpv(-113.8f*s, -201.5f*s)
        };
        moment = cpMomentForPoly(mass, numVerts, verts, CGPointZero);
        self.body = cpBodyNew(mass, moment);
        self.body->data = self;
        cpSpaceAddBody(theSpace, self.body);
        
        self->shape = cpPolyShapeNew(self.body, numVerts, verts, CGPointZero);
        
    }else if (j==1){
        int numVerts = 4;
        float s = 0.5;
        CGPoint verts[] = {
            cpv(-65.0f*s,    181.5f*s),
            cpv(104.0f*s,    164.5f*s),
            cpv(168.0f*s,   -159.5f*s),
            cpv(-164.0f*s,  -161.5f*s)
        };
        moment = cpMomentForPoly(mass, numVerts, verts, CGPointZero);
        self.body = cpBodyNew(mass, moment);
        self.body->data = self;
        cpSpaceAddBody(theSpace, self.body);
        
        self->shape = cpPolyShapeNew(self.body, numVerts, verts, CGPointZero);
    }else if (j==2){ //hotHead
        int numVerts = 5;
        float s = 0.5;
        CGPoint verts[] = {
            cpv(111.7f*s, -272.2f*s),
            cpv(-107.5f*s, -272.2f*s),
            cpv(-111.7f*s, 2.1f*s),
            cpv(-4.2f*s, 157.7f*s),
            cpv(113.1f*s, 0.7f*s)
        };
        moment = cpMomentForPoly(mass, numVerts, verts, CGPointZero);
        self.body = cpBodyNew(mass, moment);
        self.body->data = self;
        cpSpaceAddBody(theSpace, self.body);
        
        self->shape = cpPolyShapeNew(self.body, numVerts, verts, CGPointZero);
    }
    self->shape->e = 1;//0.3;
    self->shape->u = 1;//0.5;
    self->shape->data = self;
    cpSpaceAddShape(theSpace, self->shape);
    self.body->     shapesList->collision_type = MONSTER_TYPE;
}
@end
// ======================================================================================== //
// ======================================================================================== //
@implementation Player
@synthesize starRockets;
@synthesize rocket;
@synthesize weapon;
@synthesize ammo;
@synthesize maxAmmo;
+ (id)monsterInSpace:(cpSpace *)theSpace {
    
    Player *ship = nil;
    if ((ship = [[[super alloc] initWithFile:@"RocketGreen.png"] autorelease])) {
        ship.hp = 10;
        ship.hpMax = 10;
        ship.minMoveDuration = 2;
        ship.maxMoveDuration = 3;
        ship.isBoss = NO;
        ship.weapon = 0; //basic weapon, red laser
        ship.ammo = 100; //starting ammo
        ship.maxAmmo = 100;
    }
    
    //create face on ship and scale it so it fits well
    CCSprite *playerFace = [Face hero];
    playerFace.position = ccp(ship.contentSize.width*0.68, ship.contentSize.height*0.75);
    float scale = 0.40/(playerFace.contentSize.height/ship.contentSize.height);
    playerFace.scale = scale;
    

    //add the rocket
    /*
    Monster *rockets = nil;
    if ((rockets = [[super alloc] initWithSpriteFrameName:@"rocket.png"])){
        rockets.anchorPoint = ccp(0.97, 0.5);
        rockets.position = ccp(ship.contentSize.width*0.3, ship.contentSize.height/2);
        
        [rockets makeFlicker];
    }
    [ship addChild:rockets];
    */
    //add the rockets star perticles
    CCParticleFire *rocketFire = [[[CCParticleFire alloc] init] autorelease];
    rocketFire.autoRemoveOnFinish = YES;
    rocketFire.position = ccp(ship.contentSize.width*0.1, ship.contentSize.height/2);
    CCTexture2D *fireTex = [[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"exhaustStarLarge.png"]];
    rocketFire.texture = fireTex;
    rocketFire.angle = 180;
    rocketFire.speed = 500;
    rocketFire.scale = 0.25;
    rocketFire.life = 0.33;
    rocketFire.emissionRate = 30;
    [fireTex release]; fireTex = nil;
    
    [ship addChild:playerFace];
    [ship addChild:rocketFire z:ship.zOrder-1];
    ship.starRockets = rocketFire;
    return ship;
}
+ (id)rockets{
    Player *rockets = nil;
    if ((rockets = [[[super alloc] initWithSpriteFrameName:@"rocket.png"] autorelease])) {
        rockets.anchorPoint = ccp(0.97, 0.5);
        [rockets makeFlicker];
    }
    return rockets;
}
+ (id)largePlayer{
    Player *ship = nil;
    if ((ship = [[[super alloc] initWithFile:@"RocketGreenLarge.png"] autorelease])) {
        ship.hp = 10;
        ship.hpMax = 10;
        ship.minMoveDuration = 2;
        ship.maxMoveDuration = 3;
        ship.isBoss = NO;
    }
    
    //create face on ship and scale it so it fits well
    CCSprite *playerFace = [Face hero];
    playerFace.position = ccp(ship.contentSize.width*0.68, ship.contentSize.height*0.75);
    float scale = 0.40/(playerFace.contentSize.height/ship.contentSize.height);
    playerFace.scale = scale;
    
    //add the rockets
    
    CCParticleFire *rocketFire = [[[CCParticleFire alloc] init] autorelease];
    rocketFire.autoRemoveOnFinish = YES;
    rocketFire.position = ccp(ship.contentSize.width*0.1, ship.contentSize.height/2);
    CCTexture2D *fireTex = [[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"exhaustStar.png"]];
    rocketFire.texture = fireTex;
    rocketFire.angle = 180;
    rocketFire.speed = 300;
    //rocketFire.scale = 0.25;
    rocketFire.life = 0.4;
    //rocketFire.startSize = 40;
    //rocketFire.endSize = 20;
    rocketFire.emissionRate = 25;
    [fireTex release]; fireTex = nil;
    
    [ship addChild:playerFace];
    [ship addChild:rocketFire z:ship.zOrder-1];
    ship.starRockets = rocketFire;
    return ship;
}
@end
// ======================================================================================== //
@implementation Face
+ (id)face {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue

    Face *face = nil;
    int i = arc4random() % [appDelegate.activeFaceDataArray count];
    FaceData *fd = [appDelegate.activeFaceDataArray objectAtIndex:i];
    
    if ((face = [[[super alloc] initWithTexture:fd.faceCroppedTex] autorelease])) {
        face.isBoss = NO;
        face.leftEyePos =   CGPointMake(fd.leftEyePos.x, 1-fd.leftEyePos.y); //convert coordinate system
        face.rightEyePos =  CGPointMake(fd.rightEyePos.x, 1-fd.rightEyePos.y);
        face.mouthPos =     CGPointMake(fd.mouthPos.x, 1-fd.mouthPos.y);
        face.fbFriendName = fd.name;
        
        NSLog(@"feature positions set in Face sprite: \nleftEyePos: (%.2f, %.2f) \nrightEyePos: (%.2f, %.2f) \nmouthPos: (%.2f, %.2f)",
              face.leftEyePos.x, face.leftEyePos.y,
              face.rightEyePos.x, face.rightEyePos.y,
              face.mouthPos.x, face.mouthPos.y);
        
    }
    
    return face;
}
+(id)hero{
    Face *face = nil;
    FaceData *fd = [FaceData hero];
    
    if ((face = [[[super alloc] initWithTexture:fd.faceCroppedTex] autorelease])) {
        face.isBoss = NO;
        face.leftEyePos =   CGPointMake(fd.leftEyePos.x, 1-fd.leftEyePos.y); //convert coordinate system
        face.rightEyePos =  CGPointMake(fd.rightEyePos.x, 1-fd.rightEyePos.y);
        face.mouthPos =     CGPointMake(fd.mouthPos.x, 1-fd.mouthPos.y);
        face.fbFriendName = fd.name;
    }
    
    return face;
}
- (void)shootLasers{
    
    CCSprite *badProjectile = [CCSprite spriteWithFile:@"plasma.png"];
    CCSprite *badProjectile2 = [CCSprite spriteWithFile:@"plasma.png"];
    badProjectile.color = ccc3(255, 0, 0);
    badProjectile2.color = ccc3(255, 0, 0);
    
    //CGPoint newTouchLocation = [fingerOne locationInView:[CCDirector sharedDirector] openGLView]];
    
    //Add left eye laser
    badProjectile.position = [self.parent convertToWorldSpace:self.leftEyePos];
    CGPoint endPoint = ccp(-badProjectile.contentSize.width/2,[self.parent convertToWorldSpace:self.leftEyePos].y);
    
    //calculate time of laser trip
    float dx1 = badProjectile.position.x;
    float vel = 100; //px/sec
    
    //convert back to node space
    badProjectile.position = [badProjectile convertToNodeSpace:badProjectile.position];
    [self addChild:badProjectile];
    [badProjectile runAction:[CCSequence actions:
                              [CCMoveTo actionWithDuration:dx1/vel position:[badProjectile convertToNodeSpace:endPoint]],
                              [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)], nil]];
    
    //Add right eye lazer
    badProjectile2.position = ccp(self.rightEyePos.x, self.rightEyePos.y);
    endPoint = ccp(-badProjectile2.contentSize.width/2,self.position.y);

    float dx2 = badProjectile2.position.x;
    [self addChild:badProjectile2];
    [badProjectile2 runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:dx2/vel position:endPoint],
                               [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)], nil]];
}
- (void)spriteMoveFinished:(id)sender {
    CPSprite *sprite = (CPSprite *)sender;
    NSLog(@"sprite Tag %d", sprite.tag);
    [self removeChild:sprite cleanup:YES];
}
@end
@implementation FaceWithRedEyes
+ (id)face {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    
    FaceWithRedEyes *face = nil;
    int i = arc4random() % [appDelegate.activeFaceDataArray count];
    FaceData *fd = [appDelegate.activeFaceDataArray objectAtIndex:i];
    
    if ((face = [[[super alloc] initWithTexture:fd.faceCroppedTex] autorelease])) {
        face.isBoss = NO;
        face.leftEyePos =   CGPointMake(fd.leftEyePos.x, 1-fd.leftEyePos.y); //convert coordinate system
        face.rightEyePos =  CGPointMake(fd.rightEyePos.x, 1-fd.rightEyePos.y);
        face.mouthPos =     CGPointMake(fd.mouthPos.x, 1-fd.mouthPos.y);
        face.hp = 40;
        face.hpMax = 40;
        face.fbFriendName = fd.name;
        
        CCSprite *leftEye = [CCSprite spriteWithFile:@"plasma.png"];
        leftEye.position = ccp(face.contentSize.width*face.leftEyePos.x, face.contentSize.height*face.leftEyePos.y);
        face.leftEyePos = leftEye.position; //convert to actual coordinates, rather than ratio
        leftEye.color = ccc3(255, 0, 0);//[Background randomBrightColor3B];
        face.leftEye = leftEye;
        
        
        CCSprite *rightEye = [CCSprite spriteWithFile:@"plasma.png"];
        rightEye.position = ccp(face.contentSize.width*face.rightEyePos.x, face.contentSize.height*face.rightEyePos.y);
        face.rightEyePos = rightEye.position; //convert to actual coordinates, rather than ratio
        rightEye.color = ccc3(255, 0, 0);//[Background randomBrightColor3B];
        face.rightEye = rightEye;
        
        [face addChild:leftEye];
        [face addChild:rightEye];
        
        /*
        NSLog(@"feature positions set in Face sprite: \nleftEyePos: (%.2f, %.2f) \nrightEyePos: (%.2f, %.2f) \nmouthPos: (%.2f, %.2f)",
              face.leftEyePos.x, face.leftEyePos.y,
              face.rightEyePos.x, face.rightEyePos.y,
              face.mouthPos.x, face.mouthPos.y);
        */
    }
    
    return face;
}
@end
// ======================================================================================== //
@implementation WeakAndFastMonster
+ (id)monsterInSpace:(cpSpace *)theSpace{
    
    WeakAndFastMonster *monster = nil;
    if ((monster = [[[super alloc] initWithFile:@"erinPlayer.png"] autorelease])) {
    //if ((monster = [[[super alloc] initWithSpace:theSpace withImageName:@"erinPlayer.png"] autorelease])) {  
        monster.hp = 1;
        monster.minMoveDuration = 3;
        monster.maxMoveDuration = 5;
        monster.isBoss = NO;
        monster.hasFace = NO;
        
    }
    
    //Make the monster jiggle
    [monster makeSpriteJiggle];
    
    return monster;
    
}
@end
// ======================================================================================== //
@implementation WeirdMonster
+ (id)monsterInSpace:(cpSpace *)theSpace{
    
    WeirdMonster *monster = nil;
    int j = (arc4random() % 8); //COUNT OF MONSTERS
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"Monster%d.png", j]] autorelease])) {
    //if ((monster = [[[super alloc] initWithSpace:theSpace withImageName:@"AlienFuckShip.png"] autorelease])) {  
        monster.hp = 10;
        monster.minMoveDuration = 6;
        monster.maxMoveDuration = 12;
        monster.isBoss = NO;
        monster.hasFace = NO;
    }
    
    int numOfLimbs = arc4random() % 5;
    int numOfFaces = numOfLimbs;//1;//arc4random() % numOfLimbs;
    NSMutableArray *partsArr = [[NSMutableArray alloc] initWithObjects:monster, nil];
    for (int i=0; i<=numOfLimbs; i++) {
                
        j = (arc4random() % 8); //COUNT OF MONSTERS
        WeirdMonster *newPart;
        if ((newPart = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"Monster%d.png", j]] autorelease])) {
            newPart.hp = 3;
        }
        //= [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Monster%d.png", j]];
        
        
        WeirdMonster *base = [partsArr objectAtIndex:(arc4random() % [partsArr count])];
        [base addChild:newPart];
        //position new part along edge of base part
        newPart.position = [monster randomPositionOfNewPart:newPart inBasePart:base];

        [partsArr addObject:newPart];
    }
    //Add faces to random parts of the monster 
    for (int i=0; i<numOfFaces; i++) {
        WeirdMonster *randomPart;
        //do {
        randomPart = [partsArr objectAtIndex:(arc4random() % [partsArr count])];
        //} while (randomPart.tag == 1); //tag of 1 means hasFace here
        
        Face *faceToAdd = [Face face];
        float scale = 0.75/(faceToAdd.contentSize.height/monster.contentSize.height);
        faceToAdd.scale = scale;
        faceToAdd.position = ccp(randomPart.contentSize.width/2, randomPart.contentSize.height/2);
        [randomPart addChild:faceToAdd];
        randomPart.tag = 1;
        randomPart.face = faceToAdd;
        randomPart.hasFace = YES;
        //NSLog(@"face added to part");
    }
    monster.bodyPartSprites = partsArr;
    
    [monster makePartsHaveAwkwardJiggle:partsArr];
    [partsArr release]; //MEMORY FUCKS. wasn't here in past stable code
    //[monster makeSpriteJiggle];
    
    return monster;
}
@end
// ======================================================================================== //
@implementation FaceMonster
+ (id)monster {
    //NSLog(@"FaceMonster called");
    
    
    FaceMonster *monster = nil;
    
    int j = (arc4random() % 8); //COUNT OF MONSTERS
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"Monster%d.png", j]] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        monster.hp = 10;
        monster.minMoveDuration = 6;
        monster.maxMoveDuration = 8;
        monster.isBoss = NO;
        monster.hasFace = YES;
            
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    //spin the monster
    CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:(arc4random() % 8)];
    [monster runAction:[CCRepeatForever actionWithAction:rotRight]];
    
    Face *face = [Face face];
    float scale = 0.75/(face.contentSize.height/monster.contentSize.height);
    face.scale = scale;
    face.position = ccp(monster.contentSize.width/2, monster.contentSize.height/2);
    [monster addChild:face];
    
    return monster;
}
@end
// ======================================================================================== //
@implementation SnakeMonster
+ (id)monster {
    //NSLog(@"FaceMonster called");
    
    SnakeMonster *monster = nil;
    
    //int j = (arc4random() % 8); //COUNT OF MONSTERS
    
    //if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"Monster%d.png", j]] autorelease])) {
    if ((monster = [[[super alloc] initWithFile:@"HeadPieceAlien02.png"] autorelease])) {
        NSLog(@"FaceMonster initialized");
        monster.hp = 10;
        monster.minMoveDuration = 6;
        monster.maxMoveDuration = 8;
        monster.isBoss = NO;
        monster.hasFace = YES;
        monster.canCollideWithPlayer = YES;
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    
    int numOfLimbs = (arc4random() % 8) + 3;
    //int numOfFaces = numOfLimbs;//1;//arc4random() % numOfLimbs;
    NSMutableArray *partsArr = [[NSMutableArray alloc] initWithObjects:monster, nil];
    for (int i=0; i<=numOfLimbs; i++) {
        
        //j = (arc4random() % 8); //COUNT OF MONSTERS
        CCSprite *newPart = [CCSprite spriteWithFile:@"SnakePieceAlien02.png"];
        
        CCSprite *base = [partsArr objectAtIndex:[partsArr count]-1];
        [base addChild:newPart];
        //position new part along edge of base part
        newPart.position = ccp(base.contentSize.width*0.9, base.contentSize.height/2);
        [partsArr addObject:newPart];
    }
    [monster makePartsEaseBacknForth:partsArr];
    
    FaceWithRedEyes *face = [FaceWithRedEyes face];
    float scale = 0.3/(face.contentSize.height/monster.contentSize.height);
    face.scale = scale;
    face.position = ccp(monster.contentSize.width/2, monster.contentSize.height/2);
    [monster addChild:face];
    [partsArr release]; //MEMORY FUCKS. wasn't here in past stable code
    return monster;
}
@end
// ======================================================================================== //
// ================================== BIG MONSTERS ======================================== //
// ======================================================================================== //
@implementation SawMonster
+ (id)monster {
    //NSLog(@"FaceMonster called");
    
    SawMonster *monster = nil;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    UIImage *saw = [ImageProcessor imageWithImage:[UIImage imageNamed:@"sawMonsterBody.png"]
                                     scaledToSize:CGSizeMake(winSize.height*.67, winSize.height*.67)];
    
    CCTexture2D *tex = [[CCTexture2D alloc] initWithImage:saw];
    if ((monster = [[[super alloc] initWithTexture:tex] autorelease])) {
        NSLog(@"SawMonster initialized");
        monster.hp = 10;
        monster.minMoveDuration = 12;
        monster.maxMoveDuration = 16;
        monster.isBoss = NO;
        monster.hasFace = YES;
        monster.hasCustomPath = YES;
        
    }else{  
        NSLog(@"SawMonster not initialized and is nil");
    }
    [tex release];
    tex = nil;
    CCRotateTo * rotRight = [CCRotateBy actionWithDuration:1 angle:270];
    [monster runAction:[CCRepeatForever actionWithAction:rotRight]];
    
    Face *face = [Face face];
    CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:1 angle:-270];
    [face runAction:[CCRepeatForever actionWithAction:rotLeft]];
    
    float scale = 0.75/(face.contentSize.height/monster.contentSize.height);
    face.scale = scale;
    face.position = ccp(monster.contentSize.width/2, monster.contentSize.height/2);
    [monster addChild:face];
    monster.face = face;
    
    return monster;
}
@end
// ======================================================================================== //
// ======================================= BOSSES ========================================= //
// ======================================================================================== //
@implementation BossMonster
+ (id)monsterInSpace:(cpSpace *)theSpace {
    
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    
    //CCTexture2D *tex = [[CCTexture2D alloc] initWithImage:appDelegate.bossImg];
    BossMonster *monster = [FaceMonster monster];
    //if ((monster = [[[super alloc] initWithTexture:tex] autorelease])) {
        monster.scale = 1.2;
        monster.hp = 50;
        monster.minMoveDuration = 2;
        monster.maxMoveDuration = 3;
        monster.isBoss = YES;
        monster.hasFace = YES;
        
        //[tex release];
        //tex = nil;
    //}

    return monster;
}
@end
@implementation BossAppendage
+ (id)monsterInSpace:(cpSpace *)theSpace {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    
    int j = (arc4random() % [appDelegate.monsterArray count]);
    CCTexture2D *tex = [[CCTexture2D alloc] initWithImage:[appDelegate.appendageArray objectAtIndex:j]];
    
    BossAppendage *monster = nil;
    if ((monster = [[[super alloc] initWithTexture:tex] autorelease])) {
        monster.hp = 20;
        monster.minMoveDuration = 2;
        monster.maxMoveDuration = 3;
        monster.isBoss = YES;
        monster.hasFace = NO;
        
        [tex release];
        tex = nil;
        
    }
    
    return monster;
}
@end

@implementation Alien
@synthesize faceRedEyes;
@synthesize leftLaser;
@synthesize rightLaser;

+ (id)stillAlien {
    //NSLog(@"FaceMonster called");
    
    
    Alien *alien = nil;
    
    int j = (arc4random() % 3); //COUNT OF MONSTERS
    
    if ((alien = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"Alien0%d.png", j]] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        alien.hp = 10;
        alien.minMoveDuration = 1;
        alien.maxMoveDuration = 2;
        alien.isBoss = NO;
        alien.hasFace = YES;
        alien.tag = 1;
        alien.canCollideWithPlayer = YES;
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    //spin the monster
    //CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:(arc4random() % 8)];
    //[alien runAction:[CCRepeatForever actionWithAction:rotRight]];
    [alien makeSpriteJiggle];
    
    FaceWithRedEyes *face = [FaceWithRedEyes face];
    //convert position of eyes to alien's space 
    alien.leftEyePos = [face convertToWorldSpace:face.leftEyePos];
    alien.rightEyePos = [face convertToWorldSpace:face.rightEyePos];
    
    float faceToAlienRatio = 0.5;
    float scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
    face.scale = scale;
    //set the position of the face in the alien body, based on the alien imageuh
    if (j==0) {
        face.position = ccp(alien.contentSize.width*0.475, alien.contentSize.height*0.5625);
    }else if(j==1){
        face.position = ccp(alien.contentSize.width/2, alien.contentSize.height*0.60); //position slightly different
    }else{
        faceToAlienRatio = 0.3;
        face.scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
        face.position = ccp(alien.contentSize.width*0.5, alien.contentSize.height*0.52);
        face.position = ccp(alien.contentSize.width*0.475, alien.contentSize.height*0.52);
    }
    [alien addChild:face z:alien.zOrder-1];
    
    //transfer name to the alien
    alien.fbFriendName = face.fbFriendName;
    
    return alien;
}
+ (id)stillSmallAlien {
    //NSLog(@"FaceMonster called");
    
    Alien *alien = nil;
    
    int j = (arc4random() % 3); //COUNT OF MONSTERS
    
    if ((alien = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"SmallAlien0%d.png", j]] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        alien.hp = 10;
        alien.minMoveDuration = 5;
        alien.maxMoveDuration = 8;
        alien.isBoss = NO;
        alien.hasFace = YES;
        alien.tag = 1;
        alien.canCollideWithPlayer = YES;
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    //spin the monster
    //CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:(arc4random() % 8)];
    //[alien runAction:[CCRepeatForever actionWithAction:rotRight]];
    [alien makeSpriteJiggle];
    
    FaceWithRedEyes *face = [FaceWithRedEyes face];
    alien.leftEyePos = [face convertToWorldSpace:face.leftEyePos];
    alien.rightEyePos = [face convertToWorldSpace:face.rightEyePos];
    float faceToAlienRatio = 0.5;
    float scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
    face.scale = scale;
    //set the position of the face in the alien body, based on the alien imageuh
    if (j==0) {
        face.position = ccp(alien.contentSize.width*0.475, alien.contentSize.height*0.5625);
    }else if(j==1){
        face.position = ccp(alien.contentSize.width/2, alien.contentSize.height*0.60); //position slightly different
    }else{
        faceToAlienRatio = 0.3;
        face.scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
        face.position = ccp(alien.contentSize.width*0.5, alien.contentSize.height*0.52);
        face.position = ccp(alien.contentSize.width*0.475, alien.contentSize.height*0.52);
    }
    [alien addChild:face z:alien.zOrder-1];
    
    //transfer name to the alien
    alien.fbFriendName = face.fbFriendName;
    
    return alien;
}
+ (id)stillBigAlienInSpace:(cpSpace *)theSpace {
    
    Alien *alien = nil;
    
    int j = (arc4random() % 3); //COUNT OF MONSTERS
    
    if ((alien = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"BigAlien0%d.png", j]] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        alien.hp = 100;
        alien.minMoveDuration = 1;
        alien.maxMoveDuration = 3;
        alien.isBoss = NO;
        alien.hasFace = YES;
        alien.tag = 1;
        alien.canCollideWithPlayer = NO;
        alien.hasChipmunkBody = YES;
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    
    //create the face and scale to desired ratio of alien
    FaceWithRedEyes *face = [FaceWithRedEyes face];
    float faceToAlienRatio = 0.5;
    float scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
    //face.scale = scale;
    
    //set the position of the face in the alien body, based on the alien imageuh
    if (j==0) {
        face.position = ccp(alien.contentSize.width*0.475, alien.contentSize.height*0.66);
        face.scale = scale;
    }else if(j==1){
        face.position = ccp(alien.contentSize.width/2, alien.contentSize.height*0.60); //position slightly different
        face.scale = scale;
    }else{
        //face.position = ccp(alien.contentSize.width*0.475, alien.contentSize.height*0.52);
        alien.type = @"HotHead";
        faceToAlienRatio = 0.3;
        scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
        face.scale = scale;
        face.position = ccp(alien.contentSize.width*0.5, alien.contentSize.height*0.52);
    }
    
    //shift the eyes based on the face placement and scaling
    float shiftY = face.position.y - face.contentSize.height*scale/2;
    float shiftX = face.position.x - face.contentSize.width*scale/2;
    
    //set the eye position in the alien
    alien.leftEyePos =  ccp(face.leftEyePos.x*scale + shiftX, face.leftEyePos.y*scale + shiftY);
    alien.rightEyePos = ccp(face.rightEyePos.x*scale + shiftX, face.rightEyePos.y*scale + shiftY);
    
    //MAKE SURE THE EYE POSITIONS EXISTS ON ALIEN FIRST!
    if (arc4random() % 4 == 2) {
        [alien giveSpiralEyes];
    }else{
        [alien giveRedEyes];
    }
    
    [alien makeEyesFadeOut];
    
    [face removeChild:face.leftEye  cleanup:YES];
    [face removeChild:face.rightEye cleanup:YES];
    
    //transfer name to the alien
    alien.fbFriendName = face.fbFriendName;
    
    //add the face to the alien and jiggle for effect
    [alien addChild:face z:alien.zOrder-1];
    [alien makeSpriteJiggle];
    
    //add the chipmunk body. "j" reps the sprite that was rand selected
    [alien addChipmunkBody:j inSpace:theSpace];
    
    return alien;
}
+ (id)glowingAlien{
    Alien *alien = nil;
    
    
    if ((alien = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"glowAlien.png"]] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        alien.hp = 10;
        alien.minMoveDuration = 4;
        alien.maxMoveDuration = 7;
        alien.isBoss = NO;
        alien.hasFace = YES;
        alien.color = [Background randomBrightColor3B];
        alien.tag = 1;
        alien.canCollideWithPlayer = YES;
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    //flicker the glowing alien
    id dim =        [CCFadeTo actionWithDuration:0.2 opacity:100];
    id brighten =   [CCFadeTo actionWithDuration:0.2 opacity:255];
    id seq = [CCSequence actions:dim, brighten, nil];
    [alien runAction:[CCRepeatForever actionWithAction:seq]];
    [alien makeSpriteJiggle];
    
    Face *face = [Face face];
    float scale = 0.75/(face.contentSize.height/alien.contentSize.height);
    face.scale = scale;
    face.position = ccp(alien.contentSize.width/2, alien.contentSize.height/2);
    
    [alien addChild:face];
    
    return alien;
}
+ (id)hugeFaceAlien{
    Alien *alien = nil;
    
    
    if ((alien = [[[super alloc] initWithFile:[NSString stringWithFormat:@"HugeAlien02.png"]] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        alien.hp = 80;
        alien.minMoveDuration = 4;
        alien.maxMoveDuration = 7;
        alien.isBoss = NO;
        alien.hasFace = YES;
        //alien.color = [Background randomBrightColor3B];
        alien.tag = 1;
        //alien.scale = 5; //make huge
        //alien.skewY = 2;
        alien.canCollideWithPlayer = NO;
        alien.mustShootEyes = YES;
        alien.mustShootFace = YES;
        alien.type = @"HotHead";
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    //flicker the glowing alien
    //id dim =        [CCFadeTo actionWithDuration:0.2 opacity:100];
    //id brighten =   [CCFadeTo actionWithDuration:0.2 opacity:255];
    //id seq = [CCSequence actions:dim, brighten, nil];
    //[alien runAction:[CCRepeatForever actionWithAction:seq]];
    [alien makeSpriteSway];
    
    //create the face and scale to desired ratio of alien
    FaceWithRedEyes *face = [FaceWithRedEyes face];
    float faceToAlienRatio = 0.3;
    float scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
    face.scale = scale;
    face.position = ccp(alien.contentSize.width*0.5, alien.contentSize.height*0.52);
    
    //shift the eyes based on the face placement and scaling
    float shiftY = face.position.y - face.contentSize.height*scale/2;
    float shiftX = face.position.x - face.contentSize.width*scale/2;
    
    //add face to the alien body
    [alien addChild:face z:alien.zOrder-1];
    alien.face = face;
    //set the eye position in the alien
    alien.leftEyePos =  ccp(face.leftEyePos.x*scale + shiftX, face.leftEyePos.y*scale + shiftY);
    alien.rightEyePos = ccp(face.rightEyePos.x*scale + shiftX, face.rightEyePos.y*scale + shiftY);
    
    CCSprite *lEye = [[CCSprite alloc] initWithFile:@"plasma.png"];
    CCSprite *rEye = [[CCSprite alloc] initWithFile:@"plasma.png"];
    
    lEye.color = ccc3(255, 0, 0);
    rEye.color = ccc3(255, 0, 0);
    
    alien.leftEye = lEye;
    [alien addChild:lEye];
    lEye.position = alien.leftEyePos;
    
    alien.rightEye = rEye;
    [alien addChild:rEye];
    rEye.position = alien.rightEyePos;
    
    [alien.leftEye runAction:[CCFadeOut actionWithDuration:0.1]];
    [alien.rightEye runAction:[CCFadeOut actionWithDuration:0.1]];
    
    //transfer name to the alien
    alien.fbFriendName = face.fbFriendName;
    
    [face removeChild:face.leftEye  cleanup:YES];
    [face removeChild:face.rightEye cleanup:YES];
    [lEye release];
    [rEye release];
    return alien;
}
+ (id)hugeFaceAlienMovingArmsInSpace:(cpSpace *)theSpace{
    Alien *alien = nil;
    
    
    if ((alien = [[[super alloc] initWithSpriteFrameName:@"HugeAlien02Body.png"] autorelease])) {
        //NSLog(@"FaceMonster initialized");
        alien.hp = 80;
        alien.minMoveDuration = 4;
        alien.maxMoveDuration = 7;
        alien.isBoss = NO;
        alien.hasFace = YES;
        if (arc4random() % 5 == 2) {
            //sometimes, color the alien
            alien.color = [Background randomBrightColor3B];
        }
        alien.tag = 1;
        alien.canCollideWithPlayer = NO;
        alien.mustShootEyes = YES; //not used currently (11/28/12)
        alien.mustShootFace = YES; //not used currently (11/28/12)
        alien.hasChipmunkBody = YES;
        alien.appendages = [[[NSMutableArray alloc] init] autorelease];
        alien.type = @"HotHead";
        
    }else{
        NSLog(@"FaceMonster not initialized and is nil");
    }
    
    //ADD MOVING ARMS
    
    Alien *lArm;
    if ((lArm = [[[super alloc] initWithSpriteFrameName:@"Alien02LeftArm.png"] autorelease])) {
        lArm.hp = 3;
    }
    lArm.anchorPoint = ccp(1, 0);
    lArm.position = ccp(alien.contentSize.width*0.13, alien.contentSize.height*0.44);
    [lArm makePartHaveAwkwardJiggle];
    [alien addChild:lArm];
    
    Alien *rArm;
    if ((rArm = [[[super alloc] initWithSpriteFrameName:@"Alien02RightArm.png"] autorelease])) {
        rArm.hp = 3;
    }
    rArm.anchorPoint = ccp(0, 0);
    rArm.position = ccp(alien.contentSize.width*0.87, alien.contentSize.height*0.44);
    [rArm makePartHaveAwkwardJiggle];
    [alien addChild:rArm];
    
    //add to appendages array
    [alien.appendages addObject:rArm];
    [alien.appendages addObject:lArm];
    
    [alien makeSpriteSway];
    
    //create the face and scale to desired ratio of alien
    FaceWithRedEyes *face = [FaceWithRedEyes face];
    float faceToAlienRatio = 0.3;
    float scale = faceToAlienRatio/(face.contentSize.height/alien.contentSize.height);
    face.scale = scale;
    face.position = ccp(alien.contentSize.width*0.5, alien.contentSize.height*0.52);
    
    //shift the eyes based on the face placement and scaling
    float shiftY = face.position.y - face.contentSize.height*scale/2;
    float shiftX = face.position.x - face.contentSize.width*scale/2;
    
    //add face to the alien body
    [alien addChild:face z:alien.zOrder-1];
    alien.face = face;
    //set the eye position in the alien
    alien.leftEyePos =  ccp(face.leftEyePos.x*scale + shiftX, face.leftEyePos.y*scale + shiftY);
    alien.rightEyePos = ccp(face.rightEyePos.x*scale + shiftX, face.rightEyePos.y*scale + shiftY);
    
    CCSprite *lEye = [[CCSprite alloc] initWithFile:@"plasma.png"];
    CCSprite *rEye = [[CCSprite alloc] initWithFile:@"plasma.png"];
    lEye.color = ccc3(255, 0, 0);
    rEye.color = ccc3(255, 0, 0);
    
    alien.leftEye = lEye;
    [alien addChild:lEye];
    lEye.position = alien.leftEyePos;
    
    alien.rightEye = rEye;
    [alien addChild:rEye];
    rEye.position = alien.rightEyePos;
    
    [alien.leftEye runAction:[CCFadeOut actionWithDuration:0.1]];
    [alien.rightEye runAction:[CCFadeOut actionWithDuration:0.1]];
    
    
    [face removeChild:face.leftEye  cleanup:YES];
    [face removeChild:face.rightEye cleanup:YES];
    
    //transfer name to the alien
    alien.fbFriendName = face.fbFriendName;
    
    //add the chipmunk body
    float mass = 1.0;
    float moment;
    int numVerts = 4;
    float s = 0.5;
    CGPoint verts[] = {
        cpv(-103.0f*s, 216.0f*s),
        cpv(101.0f*s, 216.0f*s),
        cpv(187.0f*s, -134.0f*s),
        cpv(-199.0f*s, -136.0f*s)
    };
    
    moment = cpMomentForPoly(mass, numVerts, verts, CGPointZero);
    alien.body = cpBodyNew(mass, moment);
    alien.body->data = alien;
    cpSpaceAddBody(theSpace, alien.body);
    
    alien->shape = cpPolyShapeNew(alien.body, numVerts, verts, CGPointZero);

    alien->shape->e = 1;//0.3;
    alien->shape->u = 1;//0.5;
    alien->shape->data = alien;
    cpSpaceAddShape(theSpace, alien->shape);
    alien.body->     shapesList->collision_type = MONSTER_TYPE;
    
    
    [lEye release];
    [rEye release];
    
    return alien;
}
+ (id)cometAlien{
    
    CCSprite *dummySprite = nil;
    if ((dummySprite = [[[super alloc] initWithSpriteFrameName:@"plasma.png"] autorelease])) {
    
    }

    
    //Alien *alien = [Face face];
    
    //CCParticleMeteor *meteor = [[[CCParticleMeteor alloc] initWithTotalParticles:10] autorelease];
    //meteor.texture = alien.texture;
    //meteor.position = dummySprite.position;
    //meteor.position = ccp(alien.contentSize.width/2, alien.contentSize.height/2);
    //[dummySprite addChild:meteor];
    
    return dummySprite;
}
+ (void)addRandomBeastToLayer:(CCLayer *)layer{
    CGSize winSize = [[CCDirector sharedDirector]winSize];
    
    //START CONSTRUCTING CODE FOR RANDOM LOOKING ALIENS. HAVE LIMBS, HEAD AND BODY FOR HOT HEAD
    
    /*
    Alien *alien = nil;
    
    if ((alien = [[[super alloc] initWithFile:[NSString stringWithFormat:@"BigBodyA02.png"]] autorelease])) {
        alien.hp = 10;
        alien.minMoveDuration = 1;
        alien.maxMoveDuration = 2;
        alien.isBoss = NO;
        alien.hasFace = YES;
        alien.tag = 1;
        alien.canCollideWithPlayer = YES;
        
    }
    */
    Face *face = [Face face];
    face.position = ccp(winSize.width/2, winSize.height/2);
    
    CCParticleMeteor *meteor = [[[CCParticleMeteor alloc] initWithTotalParticles:10] autorelease];
    meteor.texture = face.texture;
    meteor.position = face.position;
    [face addChild:meteor];
    
    [face giveRandomMovesOnScreen];
    
    
    [layer addChild:face];
    
}
@end
