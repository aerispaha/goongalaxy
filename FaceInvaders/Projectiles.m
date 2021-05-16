//
//  Projectiles.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/15/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "Projectiles.h"

@implementation Projectiles
@synthesize damage;
@synthesize velocity;
@synthesize type;
@synthesize automatic;
@synthesize roundsPerSec;
@synthesize maxAmmo;
@synthesize hasFace;
@synthesize remainsAfterCollision;
@synthesize isActive;
@synthesize isCoin;
@synthesize ammoAmount;


- (void)makeStobeWithDuration:(float)duration{
    id dim =        [CCFadeTo actionWithDuration:duration opacity:50];
    id brighten =   [CCFadeTo actionWithDuration:duration opacity:255];
    id seq = [CCSequence actions:dim, brighten, nil];
    [self runAction:[CCRepeatForever actionWithAction:seq]];
}

@end

@implementation BulletItem

+ (id)item {
    
    BulletItem *item = nil;
    int numOfBulletTypes = 3; //doesn't include the basic gun, cuz its not an upgrade. why want that?
    int j = (arc4random() % numOfBulletTypes) + 1;
    if ((item = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"item%d.png", j]] autorelease])) {
        item.type = j;
        item.ammoAmount = 100;
        
        if (j==0) {
            item.maxAmmo = 100; //doesn't matter
        }else if(j==1){
            item.maxAmmo = 70;
        }else if(j==2){
            item.maxAmmo = 50;
        }else if(j==3){
            item.maxAmmo = 10;
        }
    }
    [item makeStobeWithDuration:0.1];
    return item;
}
- (id)projectile{
    Projectiles *p = nil;
    if (self.type == 0) {
        p = [RedLaser projectile];
    }else if (self.type == 1){
        p = [GreenLaser projectile];
    }else if (self.type == 2){
        p = [PurpleCurvyLaser projectile];
    }else if (self.type == 3){
        p = [FaceProjectile projectile];
    }
    NSLog(@"self.type = %d", self.type);
    return p;
}
@end
@implementation HealthItem
+ (id)item {
    
    HealthItem *item = nil;
    
    if ((item = [[[super alloc] initWithSpriteFrameName:@"wrenchHealth.png"] autorelease])) {
    
    }
    [item makeStobeWithDuration:0.1];
    return item;
}
@end
@implementation Coin
+ (id)item {
    
    Coin *coin = nil;
    
    if ((coin = [[[super alloc] initWithSpriteFrameName:@"yellowStar.png"] autorelease])) {
        
        //coin.color = ccc3(150, 200, 0);
        coin.isCoin = YES;
        /*
        id dim =        [CCFadeTo actionWithDuration:0.2 opacity:50];
        id brighten =   [CCFadeTo actionWithDuration:0.2 opacity:255];
        id seq = [CCSequence actions:dim, brighten, nil];
        [coin runAction:[CCRepeatForever actionWithAction:seq]];
        */
        [coin makeStobeWithDuration:0.2];
    }
    return coin;
}
@end
@implementation RedLaser
+ (id)projectile {
    
    RedLaser *projectile = nil;
    
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"redLaser.png"] autorelease])) {
        projectile.type = 0;
        projectile.damage = 1;
        projectile.velocity = 500/1; // 400pixels/1sec
        projectile.automatic = YES;
        projectile.roundsPerSec = 10;
        projectile.maxAmmo = 10000;
        projectile.remainsAfterCollision = NO;
        projectile.isActive = YES;
    }
    
    
    return projectile;
}

@end
@implementation GreenLaser
+ (id)projectile {
    
    GreenLaser *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"plasma.png"] autorelease])) {
        projectile.type = 1;
        projectile.damage = 2;
        projectile.velocity = 1000/1; // 500pixels/1sec
        projectile.automatic = YES;
        projectile.roundsPerSec = 20;
        projectile.maxAmmo = 100;
        projectile.color = ccc3(255, 0, 255);
        projectile.remainsAfterCollision = NO;
        projectile.isActive = YES;
        
    }
    
    return projectile;  
}
@end
@implementation PurpleCurvyLaser
+ (id)projectile {
    
    PurpleCurvyLaser *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"purpleCurveyLaser.png"] autorelease])) {
        projectile.type = 2;
        projectile.damage = 4;
        projectile.velocity = 700/1; // 480pixels/1sec
        projectile.roundsPerSec = 15;
        projectile.maxAmmo = 70;
        projectile.remainsAfterCollision = NO;
        projectile.isActive = YES;
    }
    
    return projectile;
}
@end
@implementation FaceProjectile
+ (id)projectile {
    
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    FaceProjectile *projectile = nil;
    
    //int i = arc4random() % [appDelegate.activeFaceDataArray count];
    //FaceData *fd = [appDelegate.activeFaceDataArray objectAtIndex:i];
    
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"Bomb.png"] autorelease])) {
        //[self resizeSprite:projectile toWidth:8 toHeight:8];
        projectile.type = 3;
        projectile.damage = 5;
        projectile.velocity = 100; //pxl/s
        projectile.automatic = YES;
        projectile.roundsPerSec = 5;
        projectile.maxAmmo = 20;
        projectile.remainsAfterCollision = NO;
        projectile.isActive = YES;
    }
    id rotRight = [CCRotateBy actionWithDuration:0.033 angle:(arc4random() % 8)+30];
    [projectile runAction:[CCRepeatForever actionWithAction:rotRight]];
    
return projectile;
}
+ (void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height{
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
        width   *=  2;
        height  *=  2;
    }
    
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}
@end

@implementation EvilProjectile
+ (id)longLaser {
    
    EvilProjectile *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"longRedLaser.png"] autorelease])) {
        projectile.type = 0;
        projectile.damage = 1;
        projectile.velocity = 500/1; // 500pixels/1sec
        projectile.automatic = YES;
        projectile.roundsPerSec = 10;
        projectile.remainsAfterCollision = YES;
        projectile.isActive = YES;
    }
    
    CCSprite *flasher = [CCSprite spriteWithSpriteFrameName:@"longYellowLaser.png"];
    flasher.color = ccc3(255, 255, 255);
    id fadeIn =     [CCFadeIn  actionWithDuration:0.05];
    id fadeOut =    [CCFadeOut actionWithDuration:0.05];
    id seq = [CCSequence actions:fadeOut, fadeIn, nil];
    [flasher runAction:[CCRepeatForever actionWithAction:seq]];
    flasher.position = ccp(projectile.contentSize.width/2, projectile.contentSize.height/2);
    [projectile addChild:flasher];
    
    return projectile;
}
+ (id)fireBalls {
    
    EvilProjectile *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"redStar.png"] autorelease])) {
        projectile.type = 0;
        projectile.damage = 1;
        projectile.velocity = 500/1; // 500pixels/1sec
        projectile.automatic = YES;
        projectile.roundsPerSec = 10;
        projectile.remainsAfterCollision = NO;
        projectile.isActive = YES;
        projectile.color = ccc3(255, 0, 0);
        projectile.tag = 3;
    }
    projectile.scale = 1.2;
    [projectile makeStobeWithDuration:0.1];
    [projectile runAction:[CCRotateBy actionWithDuration:0.1 angle:360]];
    
    id tintUp   = [CCTintBy actionWithDuration:0.2 red:0 green:200 blue:0];
    id tintDwn  = [CCTintBy actionWithDuration:0.2 red:0 green:-200 blue:0];
    id colorSeq = [CCSequence actions:tintUp, tintDwn, nil];
    [projectile runAction:[CCRepeatForever actionWithAction:colorSeq]];
    
    return projectile;
}
+ (id)spaceDebris {
    
    EvilProjectile *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"BigRedStar.png"] autorelease])) {
        projectile.type = 0;
        projectile.damage = 2;
        projectile.velocity = 500/1; // 500pixels/1sec
        projectile.automatic = NO;
        projectile.roundsPerSec = 10;
        projectile.remainsAfterCollision = NO;
        projectile.isActive = NO;
        projectile.tag = 3;
        projectile.rotation = 45;
    }
    
    return projectile;
}
@end
