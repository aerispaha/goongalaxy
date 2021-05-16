//
//  Projectiles.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/15/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "ImageProcessor.h"
#import "chipmunk.h"
#import "CPSprite.h"
#import "Background.h"
//#import "Monster.h"


@interface Projectiles : CPSprite{

}

@property (nonatomic, assign) int damage;
@property (nonatomic, assign) float velocity;
@property (nonatomic, assign) int  type;
@property (nonatomic, assign) BOOL automatic;
@property (nonatomic, assign) float roundsPerSec;
@property (nonatomic, assign) int  maxAmmo;
@property (nonatomic, assign) BOOL hasFace;
@property (nonatomic, assign) BOOL remainsAfterCollision;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isCoin;
@property (nonatomic, assign) int ammoAmount;

- (void)makeStobeWithDuration:(float)duration;

@end

@interface BulletItem : Projectiles {
}

+(id)item;
-(id)projectile;
@end
@interface HealthItem : Projectiles {
}
+(id)item;
@end
@interface Coin : Projectiles {
}
+(id)item;
@end
@interface RedLaser : Projectiles {
}
+(id)projectile;

@end

@interface GreenLaser : Projectiles {
}
+(id)projectile;

@end

@interface PurpleCurvyLaser : Projectiles {
}
+(id)projectile;

@end

@interface FaceProjectile : Projectiles {
    AppDelegate *appDelegate;
}
+(id)projectile;

+ (void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height;
@end

@interface EvilProjectile : Projectiles {
}
+(id)longLaser;
+(id)fireBalls;
+(id)spaceDebris;
@end