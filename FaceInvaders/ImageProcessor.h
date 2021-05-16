//
//  ImageProcessor.h
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 4/26/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>
#import "FaceData.h"

@interface ImageProcessor : NSObject{
    AppDelegate *appDelegate;
}

//FaceData compatible
+ (NSMutableArray *)activeFaceArray;
+ (UIImage *)cropFace:(UIImage *)img;



//old stuff
+ (NSMutableArray *)createMonstersArrayFromFaceFiles;
+ (NSMutableArray *)createAppendages;
+ (UIImage *)createBosses;
+ (NSMutableArray *)createPlanets;
+ (NSArray *)featureDxDyWithKey:(NSString *)feature inImage:(UIImage *)img;

+ (NSArray *)getFacesFromImage:(UIImage *)image;
//+ (NSMutableArray *)detectFacesAndSaveImageWithInfo:(UIImage *)info;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)scaleImageToWinSize:(UIImage *)image;
+ (UIImage *)scaleImageToWinsizeMaintainAspectRatio:(UIImage *)image;
+ (UIImage *)scaleImage:(UIImage *)image by:(float)scale;
+ (UIImage *)scaleImageRegardlessOfDisplayType:(UIImage *)image by:(float)scale;
+ (UIImage *)mergeImage:(UIImage *)first withImage:(UIImage*)second;
+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage *)maskImage:(UIImage *)image;
+ (UIImage *)addDamageTo:(UIImage *)image atPosition:(CGPoint )p1 relativeToPos:(CGPoint )p2;
+ (UIImage *)drawCircleOnImage:(UIImage *)img atPosition:(CGPoint)point;
+ (UIImage *)drawLeftEyePosOnImage:(UIImage *)img atPosition:(CGPoint)point;
+ (UIImage *)drawMouthPosOnImage:(UIImage *)img atPosition:(CGPoint)point;

+(UIImage*) screenshotWithStartNode:(CCNode*)startNode;
+ (ccColor3B)lightenSprite:(CCSprite *)sprite;

@property (nonatomic) CGPoint *leftEyePos;
@property (nonatomic) CGPoint *rightEyePos;
@property (nonatomic) CGPoint *mouthPos;

@end
