//
//  GamePlayerDatabase.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/7/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "GamePlayerDatabase.h"

@implementation GamePlayerDatabase


+ (NSString *)getPrivateDocsDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    
    return documentsDirectory;
    
}
+ (NSMutableArray *)loadGamePlayerDocs {
    
    // Get private docs dir
    NSString *documentsDirectory = [GamePlayerDatabase getPrivateDocsDir];
    NSLog(@"Loading gameplayers from %@", documentsDirectory);
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Create ScaryBugDoc for each file
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"gameplayer" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
            GamePlayerDoc *doc = [[[GamePlayerDoc alloc] initWithDocPath:fullPath] autorelease];
            [retval addObject:doc];
            //NSLog(@"gamePlayerDoc created from file");
        }
    }
    return retval;
 }
+ (NSMutableArray *)loadGamePlayers {
    
    // Get private docs dir
    NSString *documentsDirectory = [GamePlayerDatabase getPrivateDocsDir];
    NSLog(@"Loading gameplayers from %@", documentsDirectory);
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Create GamePlayerDoc for each file
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"gameplayer" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
            GamePlayerDoc *doc = [[[GamePlayerDoc alloc] initWithDocPath:fullPath] autorelease];
            GamePlayer *player = [doc data];
            [retval addObject:player];
            //NSLog(@"gamePlayerDoc created from file");
        }
    }
    return retval;
}
+ (NSString *)nextGamePlayerDocPath {
    
    // Get private docs dir
    NSString *documentsDirectory = [GamePlayerDatabase getPrivateDocsDir];
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Search for an available name
    int maxNumber = 0;
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"gameplayer" options:NSCaseInsensitiveSearch] == NSOrderedSame) {            
            NSString *fileName = [file stringByDeletingPathExtension];
            maxNumber = MAX(maxNumber, fileName.intValue);
        }
    }
    
    // Get available name
    NSString *availableName = [NSString stringWithFormat:@"%d.gameplayer", maxNumber+1];
    return [documentsDirectory stringByAppendingPathComponent:availableName];
    
}

@end
