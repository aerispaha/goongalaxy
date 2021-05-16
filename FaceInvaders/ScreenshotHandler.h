//
//  ScreenshotHandler.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 11/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenshotHandler : NSObject

+ (NSString *)makeScreenShotDir;
+ (NSString *)screenShotDir;
+ (NSMutableArray *)loadPathsFromDisk;
+ (void)deleteAllFiles;
@end
