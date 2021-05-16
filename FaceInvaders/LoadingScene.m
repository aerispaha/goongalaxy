//
//  LoadingScene.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/29/12.
//  Copyright 2012 EychmoTech. All rights reserved.
//

#import "LoadingScene.h"


@implementation LoadingScene{
    
}

+(CCScene *) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LoadingScene *layer = [LoadingScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
    NSLog(@"scene returned");
	return scene;
}
- (id)init{
    if( (self=[super initWithColor:ccc4(0, 0, 00, 225)])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *fntFile = @"purpleBauh93.fnt";
        CCLabelBMFont *loadingLab = [CCLabelBMFont labelWithString:@"loading..." fntFile:fntFile];
        loadingLab.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:loadingLab];
        [self schedule:@selector(loadGameUp) interval:1];
    }
    return self;
}
- (void)loadGameUp{
    NSLog(@"loadGameUp called");
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}
@end
