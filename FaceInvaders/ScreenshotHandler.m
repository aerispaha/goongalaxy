//
//  ScreenshotHandler.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 11/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "ScreenshotHandler.h"

@implementation ScreenshotHandler

+ (NSString *)makeScreenShotDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"ScreenshotArchive"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"filePathcreated: %@",documentsDirectory);
    return documentsDirectory;
}
+ (NSString *)screenShotDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"ScreenshotArchive"];
    return documentsDirectory;
}

+ (NSMutableArray *)loadPathsFromDisk{
    NSArray  *screenshotFiles  = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self screenShotDir] error:NULL];
    NSMutableArray *array = [[[NSMutableArray alloc]init] autorelease]; //MEMORY FUCKS
    for (NSString *file in screenshotFiles) {
        NSString *path = [[self screenShotDir] stringByAppendingPathComponent:file];
        [array addObject:path];
    }
    return array;
}
+ (void)deleteAllFiles{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:[self screenShotDir] error:nil];
    for (NSString *filename in fileArray)  {
        
        [fileMgr removeItemAtPath:[[self screenShotDir] stringByAppendingPathComponent:filename] error:NULL];
    }
}
@end
