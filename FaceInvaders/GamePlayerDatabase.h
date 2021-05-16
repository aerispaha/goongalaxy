//
//  GamePlayerDatabase.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/7/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GamePlayer.h"
#import "GamePlayerDoc.h"

@interface GamePlayerDatabase : NSObject

+ (NSMutableArray *)loadGamePlayerDocs;
+ (NSMutableArray *)loadGamePlayers;
+ (NSString *)nextGamePlayerDocPath;

@end
