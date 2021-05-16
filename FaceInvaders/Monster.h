//
//  Monster.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 4/20/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "chipmunk.h"
#import "CPSprite.h"
#import "FaceData.h"
#import "Background.h"
#import "Projectiles.h"


@interface Monster : CPSprite{
    AppDelegate *appDelegate;
    
    int _curHp;
    int _minMoveDuration;
    int _maxMoveDuration;
    NSString *_fbFriendName;

}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int hpMax;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;
@property (nonatomic, assign) id path;
@property (nonatomic, assign) BOOL isBoss;
@property (nonatomic, assign) BOOL hasFace;
@property (nonatomic, assign) BOOL hasCustomPath;
@property (nonatomic, assign) BOOL hasChipmunkBody;
@property (nonatomic, assign) BOOL isSpecialSequence;
@property (nonatomic, assign) BOOL isPartOfASynchGroup;
@property (nonatomic, assign) BOOL canCollideWithPlayer;
@property (nonatomic, assign) BOOL mustShootEyes;
@property (nonatomic, assign) BOOL mustShootFace;
@property (nonatomic, assign) BOOL isFlickering;
@property (nonatomic, assign) NSString *fbFriendName;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) NSMutableArray *bodyPartSprites;
@property (nonatomic, assign) CCSprite *leftEye;
@property (nonatomic, assign) CCSprite *rightEye;
@property (nonatomic, assign) CCSprite *face;
@property (nonatomic, assign) NSMutableArray *appendages;
@property (assign) CGPoint faceOffset;
@property (assign) CCSprite *monsterBody;
@property (assign) CGPoint  leftEyePos;
@property (assign) CGPoint  rightEyePos;
@property (assign) CGPoint  mouthPos;


+ (NSMutableArray *)arrayOfActiveFaceSprites;
- (CGPoint)randomPositionOfNewPart:(CCSprite *)newPart inBasePart:(CCSprite *)base;
- (CGPoint)randomSnakedPositionOfNewPart:(CCSprite *)newPart inBasePart:(CCSprite *)base;

//accent movements for monster with an array of children
- (void)makePartsHaveAwkwardJiggle:(NSArray *)array;
- (void)makePartHaveAwkwardJiggle;
- (void)makePartsEaseBacknForth:(NSArray *)array;
- (void)makeSpriteJiggle;
- (void)makeSpriteJiggleOnce;
- (void)makeSpriteSway;

//positioning
- (void)positionMonsterOffRightScreen;
- (void)positionMonsterOffBottomScreen;
- (CGPoint)randPositionOffRightScreen;
+ (CGPoint)randPositionOffRightScreen:(CCSprite *)sprite;
+ (CGPoint)randPositionOnScreen;

//movements
- (CCMoveTo *)moveCrossScreen;
- (id)randomMovesOnScreen;
- (void)giveRandomMovesOnScreen;
- (void)giveRandomMovesWithDuration:(float)duration;
- (CCMoveTo *)moveToRandomPlaceOnRightOfScreenWithDuration:(float)duration;
+ (NSArray *)arrayOfSameBeziers:(int)numberOfBeziers toPoint:(CGPoint)pos;
+ (NSArray *)arrayOfDifferentBeziers:(int)numberOfBeziersOnScreen;

//accents
- (void)giveSpiralEyes;
- (void)giveRedEyes;
- (void)makeEyesFadeOut;
- (void)makeFlicker;
- (void)stopFlciker:(id)sender;

//Chipmunk Stuff
- (void)addChipmunkBody:(int)j inSpace:(cpSpace *)theSpace;

@end
// ======================================================================================== //
// ======================================================================================== //

@interface Player : Monster
@property (nonatomic, assign) CCParticleFire *starRockets;
@property (nonatomic, assign) int weapon;
@property (nonatomic, assign) int ammo;
@property (nonatomic, assign) int maxAmmo;
@property (nonatomic, assign) Projectiles *weaponn;
@property (nonatomic, assign) Monster *rocket;

+ (id)monsterInSpace:(cpSpace *)theSpace;
+ (id)largePlayer;
+ (id)rockets;
@end
@interface Face : Monster
+ (id)face;
+ (id)hero;
@end
@interface FaceWithRedEyes : Monster
+ (id)face;
@end
@interface WeakAndFastMonster : Monster
+ (id)monsterInSpace:(cpSpace *)theSpace;
@end
@interface WeirdMonster : Monster
+ (id)monsterInSpace:(cpSpace *)theSpace;
@end
@interface FaceMonster : Monster
+ (id)monster;
@end
@interface SnakeMonster : Monster
+ (id)monster;
@end
//Big Monsters
@interface SawMonster : Monster
+ (id)monster;
@end
//Boss Monsters
@interface BossMonster : Monster
+ (id)monsterInSpace:(cpSpace *)theSpace;
@end
@interface BossAppendage : Monster
+ (id)monsterInSpace:(cpSpace *)theSpace;
@end


//Aliens
@interface Alien : Monster
@property (nonatomic, assign) FaceWithRedEyes *faceRedEyes;
@property (nonatomic, assign) EvilProjectile *leftLaser;
@property (nonatomic, assign) EvilProjectile *rightLaser;
+ (id)stillAlien;
+ (id)stillSmallAlien;
+ (id)stillBigAlienInSpace:(cpSpace *)theSpace;
+ (id)glowingAlien;
+ (id)hugeFaceAlien;
+ (id)hugeFaceAlienMovingArmsInSpace:(cpSpace *)theSpace;;
+ (id)cometAlien;
+ (void)addRandomBeastToLayer:(CCLayer *)layer;

@end

