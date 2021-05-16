//
//  GamePlayerDoc.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/7/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "GamePlayerDoc.h"
#import "GamePlayerDatabase.h"
#define kDataKey        @"Data"
#define kDataFile       @"data.plist"

@implementation GamePlayerDoc
@synthesize playerData = _data;
@synthesize docPath = _docPath;

- (id)initWithTitle:(NSString*)title rating:(float)rating {   
    if ((self = [super init])) {
        _data = [[GamePlayer alloc] initWithTitle:title rating:rating];
    }
    return self;
}
- (id)init {
    if ((self = [super init])) {        
    }
    return self;
}

- (id)initWithDocPath:(NSString *)docPath {
    if ((self = [super init])) {
        _docPath = [docPath copy];
        
    }
    return self;
}

- (BOOL)createDataPath {
    
    if (_docPath == nil) {
        self.docPath = [GamePlayerDatabase nextGamePlayerDocPath];
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_docPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
    
}
- (GamePlayer *)data {
    
    if (_data != nil) return _data;
    
    NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[[NSData alloc] initWithContentsOfFile:dataPath] autorelease];
    if (codedData == nil) return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _data = [[unarchiver decodeObjectForKey:kDataKey] retain];    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    return _data;
}
- (void)saveData {
    
    if (_data == nil) return;
    
    [self createDataPath];
    
    NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    //NSLog(@"dataPath: %@",dataPath);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    [archiver release];
    [data release];
    
}
- (void)deleteDoc {
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_docPath error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
    
}
- (void)dealloc{
    [_docPath release];
    _docPath = nil;
    [super dealloc];
}
@end
