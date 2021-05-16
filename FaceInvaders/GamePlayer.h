//
//  GamePlayer.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/5/12.
//  Copyright 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GamePlayerDatabase.h"

@interface GamePlayer : NSObject <NSCoding> {
    NSString *_name;
    long _hiScore;
    
}

@property (copy) NSString *name;
@property  long hiScore;


- (id)initWithTitle:(NSString*)title rating:(float)rating;

@end
