//
//  Achievments.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/17/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Achievments : NSObject <NSCoding>{
    
}
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSString *fileName;
@property (nonatomic, assign) NSString *filePath;
@property (nonatomic, assign) NSNumber *isAchieved;
@property (nonatomic, assign) NSDate   *dateAchieved;
@property (nonatomic, assign) NSString *reward;


//file heiarchy controls
+ (NSString *)makeAchievementsDataDir;
+ (NSString *)achievementsDataDir;
+ (NSArray *)loadDataFromDisk;
+ (void)deleteAllFiles;
//methods to initial the achievements
+ (NSArray *)createAchievements;

//check if achievements have been achieved
+ (NSArray *)achievementsWithData:(NSMutableDictionary *)gameStats;

//methods to create individual achievements
+ (Achievments *)visit3Planets;
+ (Achievments *)visit5Planets;
+ (Achievments *)visit10Planets;
+ (Achievments *)kill100Goons;
+ (Achievments *)kill200Goons;
+ (Achievments *)kill400Goons;
+ (Achievments *)collect100Coins;
+ (Achievments *)collect200Coins;
+ (Achievments *)collect400Coins;
+ (Achievments *)collect800Coins;
+ (Achievments *)killAllGoonsOnPlanet;
+ (Achievments *)travelTwoPlanetsWithoutAWrench;
+ (Achievments *)travelTwoPlanets80percentAccuracy;
+ (Achievments *)travelFourPlanets80percentAccuracy;



@end
