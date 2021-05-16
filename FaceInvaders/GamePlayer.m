//
//  GamePlayer.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/5/12.
//  Copyright 2012 EychmoTech. All rights reserved.
//

#import "GamePlayerDatabase.h"
#import "GamePlayer.h"
#define kDataKey        @"Data"
#define kDataFile       @"data.plist"



@implementation GamePlayer
@synthesize name = _name;
@synthesize hiScore = _hiScore;

- (id)initWithTitle:(NSString*)title rating:(float)rating {
    if ((self = [super init])) {
        _name  = [title copy];
        _hiScore = rating;
    }
    return self;
}



- (void)dealloc {
    [_name release];
    _name = nil;    
    [super dealloc];
}


#pragma mark NSCoding

#define kTitleKey       @"Name"
#define kRatingKey      @"HiScore"
//DELEGATE METHODS
- (void) encodeWithCoder:(NSCoder *)encoder {
    //NSLog(@"encoded");
    [encoder encodeObject:_name forKey:kTitleKey];
    [encoder encodeFloat:_hiScore forKey:kRatingKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    //NSLog(@"decoded");
    NSString *title = [decoder decodeObjectForKey:kTitleKey];
    float rating = [decoder decodeFloatForKey:kRatingKey];
    return [self initWithTitle:title rating:rating];
}
@end
