//
//  FaceData.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 9/4/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ImageProcessor.h"

@interface FaceData : NSObject <NSCoding> {
    UIImage     *_face;
    NSString    *_name;
    NSString    *_lastName;
    NSNumber     *_isActive;
    NSNumber    *_isBadGuy;
    NSNumber    *_isHero;
}

@property (nonatomic, retain)UIImage    *face;
@property (nonatomic, retain)UIImage    *faceCropped;
@property (nonatomic, retain)CCTexture2D*faceCroppedTex;
@property (nonatomic, retain)NSString   *name;
@property (nonatomic, retain)NSString   *lastName;
@property (nonatomic, retain)NSNumber   *isActive; //can't use BOOL because it's not an object?
@property (nonatomic, retain)NSNumber   *isBadGuy;
@property (nonatomic, retain)NSNumber   *isHero;
@property (nonatomic, retain)NSString   *fileName;
@property (nonatomic, retain)NSString   *faceCroppedPath;
@property (nonatomic, retain)NSString   *facebookID;
@property (assign)CGPoint    leftEyePos;
@property (assign)CGPoint    rightEyePos;
@property (assign)CGPoint    mouthPos;


+ (NSString *)makeFaceDataDir;
+ (NSString *)makeFaceDataImagesDir;
+ (NSString *)faceDataDir;
+ (NSString *)faceDataImagesDir;

+ (NSArray *)loadDataFromDisk;

+ (BOOL)createFaceDataObjectsWithImage:(UIImage *)img fromSource:(NSString *)source andName:(NSString *)name;
+ (CGPoint)convertPoint:(CGPoint)point toPointInRect:(CGRect)rect;
+ (CGPoint)rotatePoint:(CGPoint)point aboutCenter:(CGPoint)center byAngle:(float)angle;
+ (CGPoint)mirrorImageOfPoint:(CGPoint)point inRect:(CGRect)rect;
+ (NSMutableArray *)activeFaceDataArray;
+ (FaceData *)hero;

@end
