//
//  OptionsScene.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/30/12.
//  Copyright 2012 EychmoTech. All rights reserved.
//

#import "OptionsScene.h"

#define ARC4RANDOM_MAX      0x100000000

@implementation OptionsScene

+(CCScene *) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	OptionsScene *layer = [OptionsScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
    NSLog(@"scene returned");
	return scene;
}
- (id)init{
    if( (self=[super initWithColor:ccc4(0, 0, 00, 225)])) {
        winSize = [[CCDirector sharedDirector] winSize];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CCLabelTTF *loadingLab = [CCLabelTTF labelWithString:@"SOME TEXT SOME TEXT SOME TEXT v SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT v SOME TEXT SOME TEXT v SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT SOME TEXT "
                                                  dimensions:CGSizeMake(winSize.width/2, winSize.height)
                                                   alignment:NSTextAlignmentCenter
                                               lineBreakMode:NSLineBreakByWordWrapping
                                                    fontName:appDelegate.gameFont fontSize:30];
        
        loadingLab.position = ccp(winSize.width/4, winSize.height/2);
        [self addChild:loadingLab];
        [self addChild:[self optionsMenu]];
    }
    return self;
}
- (CCMenu *)optionsMenu{
    //Make main menu buttons
    
    NSString *fntFile = @"purpleBauh93.fnt";
    
    CCLabelTTF *backLab =       [CCLabelBMFont labelWithString:@"Back" fntFile:fntFile];
    CCLabelTTF *selectLab =     [CCLabelBMFont labelWithString:@"Select"  fntFile:fntFile];
    
    CCMenuItem *backButt =      [CCMenuItemLabel itemWithLabel:backLab      target:self selector:@selector(showMainMenu)];
    CCMenuItem *selectButt =    [CCMenuItemLabel itemWithLabel:selectLab    target:self selector:nil];
    
    //Make menu and fill with buttons
    optionsMenu = [CCMenu menuWithItems:backButt, selectButt, nil];
    
    for (CCMenuItem *item in optionsMenu.children) {
        //scale up and right justify with anchor point
        item.scale = 1.167;
        item.anchorPoint = ccp(1, 0.5);
        
        [self giveFunMotionToSprite:item];
    }
    
    [optionsMenu alignItemsVerticallyWithPadding:20];
    optionsMenu.position = ccp(winSize.width*0.99, winSize.height/2);
    
    return optionsMenu;
}
- (void)showMainMenu{
    NSLog(@"return to game called");
    //[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInT transitionWithDuration:0.5 scene:[IntroLayer scene]]];
    //[self buttonClick];
}
- (void)giveFunMotionToSprite:(id)sender{
    float duration = (((double)arc4random() / ARC4RANDOM_MAX)*1 + 0.75);
    int y = (arc4random() % 5) + 2;
    
    id scaleUpAction =      [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0,  y)] rate:2.0];
    id scaleDownAction =    [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0, -y)] rate:2.0];
    CCSequence *scaleSeq =  [CCSequence actions:scaleUpAction, scaleDownAction, nil];
    
    [sender runAction:[CCRepeatForever actionWithAction:scaleSeq]];
}
@end
