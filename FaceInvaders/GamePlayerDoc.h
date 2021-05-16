//
//  GamePlayerDoc.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/7/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GamePlayer;

@interface GamePlayerDoc : NSObject {
    GamePlayer *_data;
    NSString *_docPath;
}

- (GamePlayer *)data;
@property (retain) GamePlayer *playerData;
@property (copy) NSString *docPath;
- (id)init;
- (id)initWithDocPath:(NSString *)docPath;
- (id)initWithTitle:(NSString*)title rating:(float)rating;
- (void)saveData;
- (void)deleteDoc;
@end
