//
//  HelloWorldLayer.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 5/31/12.
//  Copyright EychmoTech 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"
#import "Monster.h"
#import "Projectiles.h"
#import "GameOverScene.h"
#import "CCParallaxNode-Extras.h"
#import "Background.h"
// Import Chipmunk headers
#import "chipmunk.h"
#import "cpMouse.h"
#import "CPSprite.h"
#import "drawSpace.h"
#import "GamePlayer.h"
#import "GamePlayerDoc.h"
#import "GamePlayerDatabase.h"
#import "ParticleManager.h"
#import "CollisionAssistant.h"
#import "ScreenshotHandler.h"


// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor {
    BOOL develMode;
    
    cpSpace *space; //in Chipmunk template file
    cpDampedSpring *spring; //for motion of bosses hopefully...
    
    AppDelegate *appDelegate;
    CGSize winSize;
    CGRect winRect;
    NSMutableArray *_projectiles;
    NSMutableArray *_badProjectiles;
    NSMutableArray *_targets;
    NSMutableArray *_targtsWCmkBodies;
    NSMutableArray *_crashedBagGuys;
    NSMutableArray *_items;
    NSMutableArray *_spaceDebris;
    NSMutableArray *_backgroundsItems;
    NSMutableArray *_twinkleStars;
    
    int _targetsDestroyed;
    
    //background stuff
    CCSprite *_background;
    CCParticleRain *rainStars;
    
    CGPoint pos;
    
    //moving the player
    float _shipPointsPerSecY;
    float _shipPointsPerSecX;
    Player *player;
    CCSprite *ship;
    CCParticleSystem *rocketFire;
    BOOL playerInvincible;
    BOOL playerDead;
    BOOL playerHit;
    BOOL calibration;
    float restX;
    
    //BOSS STUFF
    /*
    int timeSinceBossFight;
    FaceWithRedEyes *boss;
    CPSprite *apendage;
    CPSprite *apendage2;
    CPSprite *apendage3;
    cpConstraint *pin; 
    cpConstraint *pin2;
    cpConstraint *pin3;
    cpConstraint *dampedSpring1;
    cpConstraint *dampedSpring2;
    */
    
    
    //Special Sequence Stuff
    Alien *specialAlien;
    
    //game logic
    BOOL isBossFight;
    BOOL isSpecialSequence;
    BOOL isSynchroSequence;
    int  aliensInSynchro;
    int timeSinceBackgroundThingsAdded;
    int timeSinceBackgroundChange;
    BOOL isInSpace;
    BOOL isOnPlanet;
    BOOL targetsExist;
    BOOL terrainHasChanged;
    int gameDifficulty; //level of difficult denoted by integers, 0 being easiest, 10ish is hardest.
    
    //explosion stuff
    ParticleManager *manager;
    CCTexture2D *explosionTexture;
    CCTexture2D *shrapnelTexture;
    CCTexture2D *bombExplodeTexture;
    NSMutableArray *explosionAnimFrames;
    CCSprite *_explosion;
    CCAction *_explosionAction;
    
    //bullets stuff
    Projectiles *bullet;
    int bulletType;
    CGPoint shootingPoint;
    BOOL autoShootScheduled;
    float currentShootInterval;
    BOOL isShooting;
    
    //labels
    CCLabelBMFont *scoreLabBM;
    CCLabelBMFont *messageBoard;
    BOOL messageShown;
    
    CCSprite *healthBar;
    CCSprite *healthBulb;
    float healthBarMaxSize;
    CCSprite *ammoBar;
    CCSprite *ammoBulb;
    float ammoBarMaxSize;
    CCMenuItem *pauseButton;
    
    //parallax stuff and background stuff
    CCSprite *backgroundSpace1;
    CCSprite *backgroundSpace2;
    CCLayerColor *colorLayer;

    CCSprite *terrain;
    CCSprite *terrain2;
    CCSprite *terrain3;
    CCSprite *terrain4;
    CCSprite *backTerrain1;
    CCSprite *backTerrain2;
    Monster *floatMt;
    
    //for shifting bottom shaved background terrain
    float t34Shift;
    float btShift;
    
    CCTexture2D *planetTex1;
    UIImage *planetFace;
    CCParallaxNode *foregroundNode;
    CCParallaxNode *bkrndNode;
    CCParallaxNode *terrainNode;
    CCParallaxNode *backgroundTerNode;
    float paraSpeed;
    int descentToTerrainVel;
    
    //Hi score stuff, stats, logic
    long currentScore;
    float shotsFired;
    float shotsLanded;
    int  kills;
    NSMutableArray *planetaryKillCounts;
    NSMutableArray *planetaryGoonCounts;
    int killsOnCurrentPlanet;
    int goonsOnCurrentPlanet;
    int coinsCollected;
    int planetsVisited;
    int wrenchesUsed;
    int planetsVisitedWithoutWrench; //how many planets player travels to without picking up a wrench
    int killsSinceBigAlienFight;
    int killsSinceHugeAlienFight;
    
    
    GamePlayer *currentPlayer;
    
    //Increasing difficulty stuff
    float spawnFrequency;
    
    //pauseGameBool
    BOOL gamePaused;
    CCMenu *pauseMenu;
    CCLayerColor* pauseLayer;
    
    //debuggin stuff
    int updatesPassed;
    BOOL hasBackground;
    
    CCRenderTexture *render;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (void)handleCollisionOfBullet:(Projectiles *)projectile andMonster:(Monster *)monster;
//Explosion stuff
@property (nonatomic, retain) CCSprite *explosion;
@property (nonatomic, retain) CCAction *explosionAction;
@property (nonatomic, retain) CCSpriteBatchNode *spriteSheet;



@end
