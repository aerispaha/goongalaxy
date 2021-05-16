//
//  FaceData.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 9/4/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "FaceData.h"

@implementation FaceData

@synthesize face;
@synthesize faceCropped;
@synthesize faceCroppedTex;
@synthesize name;
@synthesize lastName;
@synthesize isActive;
@synthesize isBadGuy;
@synthesize isHero;
@synthesize fileName;
@synthesize faceCroppedPath;
@synthesize facebookID;
@synthesize leftEyePos;
@synthesize rightEyePos;
@synthesize mouthPos;

#define degreesToRadians(x) (M_PI * x / 180.0)

-(id) init {
    if((self=[super init])) {
        //what do i use this for?
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{

    if (self = [super init])
    {
     
        face =          [aDecoder decodeObjectForKey:@"face"];
        faceCropped =   [aDecoder decodeObjectForKey:@"faceCropped"];
        name =          [aDecoder decodeObjectForKey:@"name"];
        lastName =      [aDecoder decodeObjectForKey:@"lastName"];
        isActive =      [aDecoder decodeObjectForKey:@"isActive"] ;
        isBadGuy =      [aDecoder decodeObjectForKey:@"isBadGuy"];
        isHero =        [aDecoder decodeObjectForKey:@"isHero"] ;
        fileName =      [aDecoder decodeObjectForKey:@"fileName"] ;
        faceCroppedPath=[aDecoder decodeObjectForKey:@"faceCroppedPath"] ;
        facebookID =    [aDecoder decodeObjectForKey:@"facebookID"] ;
        leftEyePos =    [aDecoder decodeCGPointForKey:@"leftEyePos"] ;
        rightEyePos =   [aDecoder decodeCGPointForKey:@"rightEyePos"] ;
        mouthPos =      [aDecoder decodeCGPointForKey:@"mouthPos"];
        
        
        [face retain];
        [faceCropped retain];
        [faceCroppedTex retain];
        [name retain];
        [lastName retain];
        [isActive retain];
        [isBadGuy retain];
        [isHero retain];
        [fileName retain];
        [faceCroppedPath retain];
        [facebookID retain];

        
        
        //NSLog(@"face data decoded");
    }
    return self;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:face               forKey:@"face"];
    [aCoder encodeObject:faceCropped        forKey:@"faceCropped"];
    [aCoder encodeObject:name               forKey:@"name"];
    [aCoder encodeObject:lastName           forKey:@"lastName"];
    [aCoder encodeObject:isActive           forKey:@"isActive"];
    [aCoder encodeObject:isBadGuy           forKey:@"isBadGuy"];
    [aCoder encodeObject:isHero             forKey:@"isHero"];
    [aCoder encodeObject:fileName           forKey:@"fileName"];
    [aCoder encodeObject:faceCroppedPath    forKey:@"faceCroppedPath"];
    [aCoder encodeObject:facebookID         forKey:@"facebookID"];
    [aCoder encodeCGPoint:leftEyePos        forKey:@"leftEyePos"];
    [aCoder encodeCGPoint:rightEyePos       forKey:@"rightEyePos"];
    [aCoder encodeCGPoint:mouthPos          forKey:@"mouthPos"];
    
    
    //NSLog(@"face data encoded");
}

+ (NSString *)makeFaceDataDir{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"FaceDataArchive"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"filePathcreated: %@",documentsDirectory);
    return documentsDirectory;
}
+ (NSString *)makeFaceDataImagesDir{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"FaceDataPicturesArchive"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"filePathcreated: %@",documentsDirectory);
    return documentsDirectory;
}
+ (NSString *)faceDataImagesDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"FaceDataPicturesArchive"];
    return documentsDirectory;
}
+ (NSString *)faceDataDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"FaceDataArchive"];
    return documentsDirectory;
}

+ (NSArray *)loadDataFromDisk{
    
    NSArray  *faceDataArray  = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self faceDataDir] error:NULL];
    NSLog(@"faceDataArray path: %@", [self faceDataDir]);
    NSLog(@"faceDataArray contents: %@", faceDataArray);
    
    NSMutableArray *arrayOfFaceDataObjects = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *str in faceDataArray) {
        
        if (![str isEqualToString:@"X-Object-Type"]) {//fixes "X-Object-Type" weird bug
            NSString *path = [[FaceData faceDataDir] stringByAppendingPathComponent:str];
            NSLog(@"data path:%@", path);
            NSData *data = [NSData dataWithContentsOfFile:path];
           
            FaceData *fd = [[FaceData alloc] init];
            fd = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            NSLog(@"Loaded name: %@ \nretain count: %d", fd.name, [fd retainCount]);
            if (fd != nil) {//fixes nil fd problem
                fd.face = nil;
                fd.faceCropped = nil;
                //fd.faceCroppedTex = nil;
                [arrayOfFaceDataObjects addObject:fd];
            }else{
                NSLog(@"fd was nil at path:%@",path);
            }
            //[fd release];
        }else{
            NSLog(@"X-Object-Type found, skipped");
        }
    }
    
    //sort the faceDataArray?
    NSMutableArray *unsortedData = [[[NSMutableArray alloc] initWithArray:arrayOfFaceDataObjects] autorelease];
    NSLog(@"unsorted data.\ncount: %d",[unsortedData count]);
    
    //sort the fb peeps by name
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    arrayOfFaceDataObjects = [NSMutableArray arrayWithArray:[unsortedData sortedArrayUsingDescriptors:sortDescriptors]];//[[NSMutableArray alloc] initWithArray:[unsortedData sortedArrayUsingDescriptors:sortDescriptors]];
    
    return arrayOfFaceDataObjects;
}
+ (BOOL)createFaceDataObjectsWithImage:(UIImage *)img fromSource:(NSString *)source andName:(NSString *)name{
    NSLog(@"createFaceDataObjectsWithImage called");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    // ==================================== FACE RECOGNITION CODE ==================================== //
    
    NSLog(@"Image Orientaton = %d",img.imageOrientation);
    int orientation = img.imageOrientation;
    
    CIImage *cgImg = [CIImage imageWithCGImage:img.CGImage];
    
    //rotate image according to the user's preference.
    if (orientation == 0 && [source isEqualToString:@"camera"]) {
        NSLog(@"Orientaton = %d",img.imageOrientation);
        float angle = 0.5*M_PI;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        cgImg = [cgImg imageByApplyingTransform:transform];
    }else if (orientation == 1 && [source isEqualToString:@"camera"]){
        NSLog(@"Orientaton = %d",img.imageOrientation);
        float angle = 1.5*M_PI;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        cgImg = [cgImg imageByApplyingTransform:transform];
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    //calibrated for portrait images, detect face
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray *features = [detector featuresInImage:cgImg options:imageOptions]; //fill array with detected
    
    if (features.count>0) {
        
        NSLog(@"Found %d face(s)",features.count);
        
        for (CIFaceFeature *faceFeature in features) {
            
            //find angle of face and correct
            float faceAngle = ccpAngleSigned(faceFeature.leftEyePosition, faceFeature.rightEyePosition);
            NSLog(@"face trigonometry:\nmouthPos: (%.f, %.f)\nLeftEyePos: (%.f, %.f)\nrightEyePos: (%.f, %.f)\nangle: %.3f",
                  faceFeature.mouthPosition.x, faceFeature.mouthPosition.y,
                  faceFeature.leftEyePosition.x, faceFeature.leftEyePosition.y,
                  faceFeature.rightEyePosition.x, faceFeature.rightEyePosition.y, faceAngle);
            //[appDelegate.debuggerImages addObject:[UIImage imageWithCIImage:cgImg]];
            
            CGRect imgRect = CGRectMake(0, 0, [UIImage imageWithCIImage:cgImg].size.width,[UIImage imageWithCIImage:cgImg].size.height);
            CGRect faceRect = faceFeature.bounds;
            
            //positions in original image (not sure why the mirror image is needed, but works)
            CGPoint lePos = faceFeature.leftEyePosition;
            CGPoint rePos = faceFeature.rightEyePosition;
            CGPoint mPos  = faceFeature.mouthPosition; 
            
            //positions in faceFeature.bounds rect
            NSLog(@"imgRect: (%.f, %.f)", imgRect.size.width, imgRect.size.height);
            CGPoint lePosInFaceRect = [self convertPoint:lePos toPointInRect:faceRect];
            CGPoint rePosInFaceRect = [self convertPoint:rePos toPointInRect:faceRect];
            CGPoint mPosInFaceRect  = [self convertPoint:mPos  toPointInRect:faceRect];
            
            //get position of features as ratio of width and height of faceRect (this was we can scale easily later)
            CGPoint lePosRatio =    CGPointMake(lePosInFaceRect.x/faceRect.size.width,    lePosInFaceRect.y/faceRect.size.height);
            CGPoint rePosRatio =    CGPointMake(rePosInFaceRect.x/faceRect.size.width,    rePosInFaceRect.y/faceRect.size.height);
            CGPoint mPosRatio =     CGPointMake(mPosInFaceRect.x/faceRect.size.width,     mPosInFaceRect.y/faceRect.size.height);
            
            //[appDelegate.debuggerImages addObject:[UIImage imageWithCIImage:cgImg]];
            
            //Crop out face, ROTATE face back, after adjusting for portrait
            float angle = 1.5*M_PI;
            CGAffineTransform angleNinety = CGAffineTransformMakeRotation(angle);
            float rScl = 1.1;
            CGRect slightlyBiggerFaceRect =
            CGRectMake(faceFeature.bounds.origin.x + (faceFeature.bounds.size.width  - faceFeature.bounds.size.width *rScl)/2,
                       faceFeature.bounds.origin.y + (faceFeature.bounds.size.height - faceFeature.bounds.size.height*rScl)/2,
                       faceFeature.bounds.size.width    *rScl,
                       faceFeature.bounds.size.height   *rScl);
        
            CIImage *ciFace = [[cgImg imageByCroppingToRect:slightlyBiggerFaceRect] imageByApplyingTransform:angleNinety];
            
            UIImage *face = [UIImage imageWithCIImage:ciFace];
            //[appDelegate.debuggerImages addObject:face];
            UIImage *faceSized = [ImageProcessor imageWithImage:face scaledToSize:CGSizeMake(150, 150)];
                    
    // ==================================== CREATE FACEDATA  ==================================== //
            
            FaceData *faceData = [[FaceData alloc] init];
            
            faceData.name = name; NSLog(@"detected face name: %@",faceData.name);
            NSNumber *num = [[NSNumber alloc] initWithInt:0];
            faceData.isHero     = num;
            faceData.isBadGuy   = num;
            faceData.isActive   = num;
            faceData.leftEyePos =   lePosRatio; 
            faceData.rightEyePos =  rePosRatio; 
            faceData.mouthPos =     mPosRatio;  
            
            NSLog(@"feature positions set in faceData Object: \nleftEyePos: (%.2f, %.2f) \nrightEyePos: (%.2f, %.2f) \nmouthPos: (%.2f, %.2f)",
                  faceData.leftEyePos.x, faceData.leftEyePos.y,
                  faceData.rightEyePos.x, faceData.rightEyePos.y,
                  faceData.mouthPos.x, faceData.mouthPos.y);
            
            //save with a random digit to avoid overwriting (kinda a cop-out?)
            NSString *faceDataFileName = [NSString stringWithFormat:@"%@_%d%d%d%d%d%d%d",
                                  faceData.name,  arc4random()%9,
                                  arc4random()%9, arc4random()%9,
                                  arc4random()%9, arc4random()%9,
                                  arc4random()%9, arc4random()%9];
            
            NSString *faceDataPath = [[FaceData faceDataDir] stringByAppendingPathComponent:faceDataFileName];
            NSString *fdImagePath  = [[FaceData faceDataImagesDir] stringByAppendingPathComponent:
                                      [NSString stringWithFormat:@"pic_%@",faceDataFileName]];
            
            faceData.fileName = faceDataFileName;
            faceData.faceCroppedPath = fdImagePath;
            faceData.isActive = [NSNumber numberWithInt:1]; //make active automatically
            [faceData setFaceCropped:[ImageProcessor cropFace:faceSized]]; //maybe don't save this here. it just gets 'nil-ed' at end...
            faceData.face = nil; //this is not needed after the cropped face is created.
            
            //save the faceData object to file (without the image)
            if ([NSKeyedArchiver archiveRootObject:faceData toFile:faceDataPath]) {
                NSLog(@"faceData object saved to: %@", faceDataPath);
                
                /*
                if (!appDelegate.faceDataArray){
                    NSLog(@"appDelegate.faceDataArray is nil");
                    appDelegate.faceDataArray = [[NSMutableArray alloc] initWithArray:[FaceData loadDataFromDisk]];
                }
                */
                [appDelegate.faceDataArray addObject:faceData]; //crashed here after no fucking reason.
            
            }else{
                NSLog(@"did NOT write to: %@", faceDataPath);
            }
            //save the cropped face image to file. (FaceData object with reference this via their 'faceCroppedPath')
            if ([NSKeyedArchiver archiveRootObject:faceData.faceCropped toFile:fdImagePath]) {
                NSLog(@"faceCropped saved to: %@", fdImagePath);
                //clear out the image from the faceData object, for less memory usage
                faceData.faceCropped = nil;
                
            }else{
                NSLog(@"did NOT write to: %@", fdImagePath);
                
            }
            [num release];
            [faceData release];
        
        }
        NSLog(@"createFaceDataObjectsWithImage created %d face(s)",[features count]);
        return YES;
    }else {
        NSLog(@"createFaceDataObjectsWithImage returned no faces");
        return NO;
    }
}
+ (CGPoint)convertPoint:(CGPoint)point toPointInRect:(CGRect)rect{
    
    NSLog(@"convertPoint in rect called");
    NSLog(@"point: (%.f, %.f)", point.x, point.y);
    
    CGPoint newPoint;
    // point at upper right of rect
    CGPoint maxRectPos = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    NSLog(@"maxRectPos: (%.f, %.f)", maxRectPos.x, maxRectPos.y);
    //if point is within the rect, convert to the rect's space
    if (point.x >= rect.origin.x &&
        point.y >= rect.origin.y &&
        point.x <= maxRectPos.x &&
        point.y <= maxRectPos.y) {
        newPoint = CGPointMake(point.y - rect.origin.y, point.x - rect.origin.x);
        
        NSLog(@"newPoint: (%.f, %.f)", newPoint.x, newPoint.y);
        return newPoint;
    }else{
        //return nil if point is not within rect (ignored)
        return CGPointMake(point.y - rect.origin.y, point.x - rect.origin.x);//CGPointMake(0, 0);
    }
}
+ (CGPoint)rotatePoint:(CGPoint)point aboutCenter:(CGPoint)center byAngle:(float)angle{
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(angle);
    CGAffineTransform customRotation = CGAffineTransformConcat(CGAffineTransformConcat
                                                               (CGAffineTransformInvert(translateTransform), rotationTransform), translateTransform);
    
    CGPoint rotatedPoint = CGPointApplyAffineTransform(point, customRotation);
    return rotatedPoint;
}
+ (CGPoint)mirrorImageOfPoint:(CGPoint)point inRect:(CGRect)rect{
    int posOfMiddle = rect.size.height/2;
    int dy = point.y - posOfMiddle;
    
    return CGPointMake(point.x, point.y - 2*dy);
}
+ (CGPoint)xmirrorImageOfPoint:(CGPoint)point inRect:(CGRect)rect{
    int posOfMiddle = rect.size.width/2;
    int dx = point.x - posOfMiddle;
    
    return CGPointMake(point.x - 2*dx, point.y);
}
+ (NSMutableArray *)activeFaceDataArray{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    
    //FaceData *fdObj = [[FaceData alloc]init]; //leaks?
    
    for (FaceData *fdObj in appDelegate.faceDataArray) {
        NSLog(@"faceDataArray count: %d \nname: %@", [appDelegate.faceDataArray count], fdObj.name);
        if ([fdObj.isActive intValue] == 1) {
            //unarchive the associated image from the images directory, create cctexture
            //texture created here because CCTexture2D doesn't conform to NSCoding
            UIImage *imgFromFile = [NSKeyedUnarchiver unarchiveObjectWithFile:fdObj.faceCroppedPath];
            CCTexture2D *faceTex = [[CCTexture2D alloc] initWithImage:imgFromFile];
            fdObj.faceCroppedTex = faceTex;
            NSLog(@"active: %@ \nretain count: %d", fdObj.name, [fdObj retainCount]);
            [array addObject:fdObj];
            [faceTex release]; faceTex = nil;
        }
    }
    NSLog(@"activeFaceArray count: %d", [array count]);
    //[fdObj release];
    
    return array;
}
+ (FaceData *)hero{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    
    //set a random hero in case none are selected;
    FaceData * hero = [appDelegate.faceDataArray objectAtIndex:arc4random() % [appDelegate.faceDataArray count]];
    for (FaceData *fdObj in appDelegate.faceDataArray) {
        NSLog(@"faceDataArray count: %d \nname: %@", [appDelegate.faceDataArray count], fdObj.name);
        if ([fdObj.isHero intValue] == 1) {
            //unarchive the associated image from the images directory, create cctexture
            //texture created here because CCTexture2D doesn't conform to NSCoding
            UIImage *imgFromFile = [NSKeyedUnarchiver unarchiveObjectWithFile:fdObj.faceCroppedPath];
            CCTexture2D *faceTex = [[CCTexture2D alloc] initWithImage:imgFromFile];
            fdObj.faceCroppedTex = faceTex;
            NSLog(@"hero: %@ \nretain count: %d", fdObj.name, [fdObj retainCount]);
            [faceTex release]; faceTex = nil;
            hero = fdObj;
            break;
        }
    }
    return hero;
}
- (void)dealloc
{
    /*
    [face release];
    [name release];
    [lastName release];
    [isActive release];
    [isBadGuy release];
    [isHero release];
    [fileName release];
    [facebookID release];
    */
    [super dealloc];
}
@end
