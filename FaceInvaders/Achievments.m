//
//  Achievments.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/17/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "Achievments.h"

@implementation Achievments

@synthesize name;
@synthesize fileName;
@synthesize filePath;
@synthesize isAchieved;
@synthesize dateAchieved;
@synthesize reward;

//encoder methods
- (id) initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init])
    {
        //properties representing achievements. for NSNumber bools 1 = yes, 0 = no
        name = [aDecoder decodeObjectForKey:@"name"];
        fileName = [aDecoder decodeObjectForKey:@"fileName"];
        isAchieved = [aDecoder decodeObjectForKey:@"isAchieved"];
        dateAchieved = [aDecoder decodeObjectForKey:@"dateAchieved"];
        reward = [aDecoder decodeObjectForKey:@"reward"];

        [name retain];
        [fileName retain];
        [isAchieved retain];
        [dateAchieved retain];
        [reward retain];
        
    }
    return self;
}
- (void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:fileName forKey:@"fileName"];
    [aCoder encodeObject:isAchieved forKey:@"isAchieved"];
    [aCoder encodeObject:dateAchieved forKey:@"dateAchieved"];
    [aCoder encodeObject:reward forKey:@"reward"];
    
}
//file heiarchy controls
+ (NSString *)makeAchievementsDataDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"AchievementsArchive"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"filePathcreated: %@",documentsDirectory);
    
    return documentsDirectory;
}
+ (NSString *)achievementsDataDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"AchievementsArchive"];
    return documentsDirectory;
}
+ (NSArray *)loadDataFromDisk{
    
    NSArray  *achievementsArray  = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self achievementsDataDir] error:NULL];
    NSLog(@"achievementsArray path: %@", [self achievementsDataDir]);
    NSLog(@"achievementsArray contents: %@", achievementsArray);
    
    NSMutableArray *arrayOfAchievementObjects = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *str in achievementsArray) {
        

        NSString *path = [[self achievementsDataDir] stringByAppendingPathComponent:str];
        NSData *data = [NSData dataWithContentsOfFile:path];
            
        Achievments *achievement;
        achievement = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
        if (achievement != nil) {//fixes nil fd problem
            [arrayOfAchievementObjects addObject:achievement];
        }else{
            NSLog(@"achievements was nil at path:%@",path);
        }
        
        
    }
    return arrayOfAchievementObjects;
}
+ (NSArray *)createAchievements{
    NSMutableArray *achievements = [[[NSMutableArray alloc] init] autorelease];
    
    //create achievement objects
    [achievements addObject:[Achievments visit3Planets]];
    [achievements addObject:[Achievments visit5Planets]];
    [achievements addObject:[Achievments visit10Planets]];
    [achievements addObject:[Achievments kill100Goons]];
    [achievements addObject:[Achievments kill200Goons]];
    [achievements addObject:[Achievments kill400Goons]];
    [achievements addObject:[Achievments collect100Coins]];
    [achievements addObject:[Achievments collect200Coins]];
    [achievements addObject:[Achievments collect400Coins]];
    [achievements addObject:[Achievments collect800Coins]];
    [achievements addObject:[Achievments killAllGoonsOnPlanet]];
    [achievements addObject:[Achievments travelTwoPlanetsWithoutAWrench]];
    [achievements addObject:[Achievments travelTwoPlanets80percentAccuracy]];
    [achievements addObject:[Achievments travelFourPlanets80percentAccuracy]];
    
    //write to file
    for (Achievments *achievement in achievements) {
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        [NSKeyedArchiver archiveRootObject:achievement toFile:path];
    }
    
    return achievements;
}
+ (void)deleteAllFiles{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:[self achievementsDataDir] error:nil];
    for (NSString *filename in fileArray)  {
        
        [fileMgr removeItemAtPath:[[self achievementsDataDir] stringByAppendingPathComponent:filename] error:NULL];
    }
    
    //replace with default list of achievement, with none achieved.
    [self createAchievements];
}

//check if achievements have been achieved
+ (NSArray *)achievementsWithData:(NSMutableDictionary *)gameStats{
    
    
    Achievments *achievement;
    int numOfAchievements = 0;
    NSMutableArray *achievements = [[NSMutableArray alloc] init];
    
    //travel to 3 planets
    if ([[gameStats objectForKey:@"planetsVisited"]intValue] >= 3) {
        
        //open up the existing achievement object
        achievement = [Achievments visit3Planets];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Travel to 3 planets - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //travel to 5 planets
    if ([[gameStats objectForKey:@"planetsVisited"]intValue] >= 5) {
        
        //open up the existing achievement object
        achievement = [Achievments visit5Planets];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Travel to 3 planets - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //travel to 10 planets
    if ([[gameStats objectForKey:@"planetsVisited"]intValue] >= 10) {
        
        //open up the existing achievement object
        achievement = [Achievments visit10Planets];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Travel to 3 planets - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //100 Kills
    if ([[gameStats objectForKey:@"totalKills"] intValue] >= 100) {
        
        //open up the existing achievement object
        achievement = [Achievments kill100Goons];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"One Hundred Kills - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //200 Kills
    if ([[gameStats objectForKey:@"totalKills"] intValue] >= 200) {
        
        //open up the existing achievement object
        achievement = [Achievments kill200Goons];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //400 Kills
    if ([[gameStats objectForKey:@"totalKills"] intValue] >= 400) {
        
        //open up the existing achievement object
        achievement = [Achievments kill400Goons];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //collect 100 coins
    if ([[gameStats objectForKey:@"coinsCollected"] intValue] >= 100) {
        
        //open up the existing achievement object
        achievement = [Achievments collect100Coins];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Collected 100 Coins"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //collect 200 coins
    if ([[gameStats objectForKey:@"coinsCollected"] intValue] >= 200) {
        
        //open up the existing achievement object
        achievement = [Achievments collect200Coins];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Collected 200 Coins"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //collect 400 coins
    if ([[gameStats objectForKey:@"coinsCollected"] intValue] >= 400) {
        
        //open up the existing achievement object
        achievement = [Achievments collect400Coins];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Collected 200 Coins"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //collect 800 coins
    if ([[gameStats objectForKey:@"coinsCollected"] intValue] >= 800) {
        
        //open up the existing achievement object
        achievement = [Achievments collect800Coins];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Collected 200 Coins"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //kill all on any given planet
    NSArray *planetaryKills;// = [[[NSArray alloc] init] autorelease];
    NSArray *planetaryGoons;// = [[[NSArray alloc] init] autorelease];
    planetaryKills = [gameStats objectForKey:@"planetaryKillCounts"];
    planetaryGoons = [gameStats objectForKey:@"planetaryGoonCounts"];
    for (int i = 0; i < [planetaryGoons count]; i ++) {
        NSLog(@"\nplanetaryGoons: %d\nplanetaryKills: %d",
              [[planetaryGoons objectAtIndex:i] intValue],
              [[planetaryKills objectAtIndex:i] intValue]);
        
        int survivors = [[planetaryGoons objectAtIndex:i] intValue] - [[planetaryKills objectAtIndex:i] intValue];
        NSLog(@"survivors: %d", survivors);
        //if there were more an 0 goons, and no survivors,  all were killed
        if (survivors == 0 && [[planetaryGoons objectAtIndex:i] intValue] !=0) {
            //open up the existing achievement object
            achievement = [Achievments killAllGoonsOnPlanet];
            NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
            achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            
            //if not already achieved, update achievement and save
            if (!achievement.isAchieved) {
                achievement.isAchieved = [NSNumber numberWithInt:1];
                //achievement.name = [NSString stringWithFormat:@"30 Kills on a Planet - Achieved!"];
                NSLog(@"%@", achievement.name);
                achievement.dateAchieved = [NSDate date];
                [NSKeyedArchiver archiveRootObject:achievement toFile:path];
                numOfAchievements++;
                [achievements addObject:achievement];
            }
        }
    }
    
    //kill 30 on any given planet
    for (NSNumber *kills in planetaryKills) {
        if ([kills intValue] >= 30) {
            
            //open up the existing achievement object
            achievement = [Achievments collect100Coins];
            NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
            achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            
            //if not already achieved, update achievement and save
            if (!achievement.isAchieved) {
                achievement.isAchieved = [NSNumber numberWithInt:1];
                //achievement.name = [NSString stringWithFormat:@"30 Kills on a Planet - Achieved!"];
                NSLog(@"%@", achievement.name);
                achievement.dateAchieved = [NSDate date];
                [NSKeyedArchiver archiveRootObject:achievement toFile:path];
                numOfAchievements++;
                [achievements addObject:achievement];
            }
        }
    }
    //travel to 2 planets without wrench
    if ([[gameStats objectForKey:@"planetsVisitedWithoutWrench"] intValue] >= 2) {
        
        //open up teh existing achievement object
        achievement = [Achievments travelTwoPlanetsWithoutAWrench];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Travel 2 planets without any wrenches - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //Travel 2 planets with 80% accuracy
    if ([[gameStats objectForKey:@"accuracy"] floatValue] >= 80 && [[gameStats objectForKey:@"planetsVisited"] intValue] >=2) {
        
        //open up teh existing achievement object
        achievement = [Achievments travelTwoPlanets80percentAccuracy];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Travel 2 planets with 80%% accuracy - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            
            NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    //Travel 4 planets with 80% accuracy
    if ([[gameStats objectForKey:@"accuracy"] floatValue] >= 80 && [[gameStats objectForKey:@"planetsVisited"] intValue] >=4) {
        
        //open up teh existing achievement object
        achievement = [Achievments travelFourPlanets80percentAccuracy];
        NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //if not already achieved, update achievement and save
        if (!achievement.isAchieved) {
            achievement.isAchieved = [NSNumber numberWithInt:1];
            //achievement.name = [NSString stringWithFormat:@"Travel 4 planets with 80%% accuracy - Achieved!"];
            NSLog(@"%@", achievement.name);
            achievement.dateAchieved = [NSDate date];
            
            NSString *path = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
            [NSKeyedArchiver archiveRootObject:achievement toFile:path];
            numOfAchievements++;
            [achievements addObject:achievement];
        }
    }
    
    
    NSLog(@"totalKills: %d",[[gameStats objectForKey:@"totalKills"] intValue]);
    NSLog(@"planetsVisited: %d",[[gameStats objectForKey:@"planetsVisited"]intValue]);
    NSLog(@"coinsCollected: %d",[[gameStats objectForKey:@"coinsCollected"] intValue]);
    NSLog(@"planetsVisitedWithoutWrench: %d", [[gameStats objectForKey:@"planetsVisitedWithoutWrench"] intValue]);
    NSLog(@"accuracy: %.f", [[gameStats objectForKey:@"accuracy"] floatValue]);
    
    BOOL isAchievementUnlocked = NO;
    if (numOfAchievements > 0) {
        isAchievementUnlocked = YES;
    }
    return achievements;
}

//methods to create individual achievements
+ (Achievments *)visit3Planets{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Travel to 3 planets"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)visit5Planets{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Travel to 5 planets"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)visit10Planets{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Travel to 10 planets"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)kill100Goons{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"100 Goon Kills"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)kill200Goons{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"200 Goon Kills"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)kill400Goons{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"400 Goon Kills"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)collect100Coins{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Collect 100 coins"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)collect200Coins{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Collect 200 coins"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)collect400Coins{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Collect 400 coins"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)collect800Coins{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Collect 800 coins"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)killAllGoonsOnPlanet{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Kill all goons on a planet"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)travelTwoPlanetsWithoutAWrench{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Travel 2 planets without any wrenches"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)travelTwoPlanets80percentAccuracy{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Travel 2 planets 80%% accuracy"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
+ (Achievments *)travelFourPlanets80percentAccuracy{
    Achievments *achievement;
    if ((achievement = [[[Achievments alloc] init] autorelease])) {
        achievement.name = [NSString stringWithFormat:@"Travel 4 planets 80%% accuracy"];
        achievement.fileName = achievement.name;
        achievement.filePath = [[Achievments achievementsDataDir] stringByAppendingPathComponent:achievement.fileName];
        achievement.isAchieved = NO;
        achievement.dateAchieved = nil;
        achievement.reward = nil;
    }
    return achievement;
}
@end
