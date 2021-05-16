//
//  ImageProcessor.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 4/26/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "ImageProcessor.h"

@implementation ImageProcessor
@synthesize leftEyePos;
@synthesize rightEyePos;
@synthesize mouthPos;

static int maskSize = 30;
#define degreesToRadians(x) (M_PI * x / 180.0)

+ (NSMutableArray *)activeFaceArray{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    //FaceData *fdObj;
    //fdObj = [[FaceData alloc]init];
    
    for (FaceData *fdObj in appDelegate.faceDataArray) {
        
        if ([fdObj.isActive intValue] == 1) {
            //NSLog(@"adding fdObj.face player");
            UIImage *img = fdObj.faceCropped;
            //CCTexture2D *faceTex = [[CCTexture2D alloc] initWithImage:fdObj.faceCropped];
            //fdObj = [CCSprite spriteWithTexture:faceTex];
            //fdObj.texture = faceTex;
            NSLog(@"leftEyePos: (%.f,%.f)", fdObj.leftEyePos.x, fdObj.leftEyePos.y);
            NSLog(@"faceCropped size: (%.f,%.f)", fdObj.faceCropped.size.width, fdObj.faceCropped.size.height);
            
            [array addObject:img];
        }
    }
    //NSLog(@"activeFaceArray count: %d", [array count]);
    //[fdObj release];
    return array;
}

+ (NSMutableArray *)createPlanets{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    
    //FaceData *fdObj;
    //fdObj = [[FaceData alloc]init];
    
    for (FaceData *fdObj in appDelegate.activeFaceDataArray) {
        
        //if ([fdObj.isActive intValue] == 1) {
            UIImage *face = fdObj.faceCropped;
            
            UIImage *planet = [UIImage imageNamed:@"bluePlanet5.png"];
            face = [ImageProcessor imageWithImage:face scaledToSize:CGSizeMake(planet.size.width*0.8, planet.size.height*0.8)];
            
            UIImage *planetFace = [ImageProcessor mergeImage:planet withImage:face];
            
            [array addObject:planetFace];
        //}
    }
    //[fdObj release];
    return array;
}
+ (NSMutableArray *)createMonstersArrayFromFaceFiles{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; 
    
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    
    //FaceData *fdObj;
    //fdObj = [[FaceData alloc]init];
    
    for (FaceData *fdObj in appDelegate.activeFaceDataArray) {
        //if ([fdObj.isActive intValue] == 1) { //if the face is active, use.
        
            //Create the monster body (size it)
            NSString *mask = [NSString stringWithFormat:@"Monster%d.png",arc4random() % 8];
            UIImage *maskImg = [self imageWithImage:[UIImage imageNamed:mask] scaledToSize:CGSizeMake(50, 50)]; //RETINA ISSUE
            
            //size and mask the face
            UIImage *face = fdObj.face;
            UIImage *imgSized = [self imageWithImage:face scaledToSize:CGSizeMake(30, 30)]; //retina issue
            UIImage *faceSizedAndMasked = [self maskImage:imgSized withMask:[UIImage imageNamed:@"bigMaskInv.png"]];

            //place face on top of alien body, then resize again
            UIImage *monsterFace = [self mergeImage:faceSizedAndMasked withImage:maskImg];
            CGSize monsterSize = CGSizeMake(monsterFace.size.width * 0.75, monsterFace.size.height * 0.75);
            monsterFace = [self imageWithImage:monsterFace scaledToSize:monsterSize]; //RETINA ISSUE
            
            [array addObject:monsterFace];
            NSLog(@"monster fdObj.isActive: %d", [fdObj.isActive intValue]);
        //}
        [fdObj release]; //works without this
    }
    return array;
}
+ (NSMutableArray *)createAppendages{
    //hard code which images to use here
    NSLog(@"createAppendages called");
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int numOfFiles = 8;
    for (int i = 0; i<=numOfFiles; i++) {
        NSString *imgStg = [NSString stringWithFormat:@"Monster%d.png",arc4random() % numOfFiles];
        UIImage *img = [self scaleImage:[UIImage imageNamed:imgStg] by:0.125]; //RETINA ISSUE
        
        [array addObject:img];
    }
    NSLog(@"createAppendages done");
    return array;
}
+ (UIImage *)createBosses{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //FaceData *fdObj = [[FaceData alloc] init];
    UIImage *monsterFace = nil;
    //NSLog(@"appDelegate.faceDataArray = %@",appDelegate.faceDataArray);
    do {
        //pick random active faceData Object (not efficient, should sort or something)
        NSLog(@"faceDataArray count: %d",[appDelegate.faceDataArray count]);
        int i = (arc4random() % [appDelegate.faceDataArray count]);
        NSLog(@"boss selected: %d",i);
        FaceData *fdObj = [appDelegate.faceDataArray objectAtIndex:i];
        if (fdObj != nil) {
            
            //check if it's active
            
            //MEMORY ISSUE HERE!!!!!
            //MEMORY ISSUE HERE!!!!!
            //MEMORY ISSUE HERE!!!!!
            //MEMORY ISSUE HERE!!!!!
            
            if ([fdObj.isActive intValue] == 1) { //if the face is active, use.
                
                //UIImage *imgSized = [self imageWithImage:fdObj.face scaledToSize:CGSizeMake(100, 100)]; //RETINA ISSUE
                UIImage *face = fdObj.faceCropped; //[self maskImage:imgSized withMask:[UIImage imageNamed:@"bigMaskInv.png"]];
                NSString *mask = [NSString stringWithFormat:@"Monster%d.png",arc4random() % 8];
                UIImage *maskImg = [self imageWithImage:[UIImage imageNamed:mask] scaledToSize:CGSizeMake(110, 110)]; //RETINA ISSUE
                monsterFace = [self mergeImage:face withImage:maskImg];
                NSLog(@"Boss image created");
                
            }else{
            NSLog(@"Boss image NOT active, not created");
        }
        
        }else{
          NSLog(@"fdObj is nil, boss not created");
        }
    } while (monsterFace == nil);
        
        //[fdObj release]; //works without this
    
    return monsterFace;
}
+ (NSArray *)featureDxDyWithKey:(NSString *)feature inImage:(UIImage *)img{
    
    if (img == nil) { NSLog(@"img is nill");}else {NSLog(@"img not nil");}
    //UIImage *imgSized = [self imageWithImage:img scaledToSize:CGSizeMake(320, 480)];
    CIImage *cgImg = [CIImage imageWithCGImage:img.CGImage];
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    //calibrated for portrait images, detect face
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray *features = [detector featuresInImage:cgImg options:imageOptions]; //fill array with detected
    
    if (features.count>0) {
        NSLog(@"Found %d face(s)",features.count);
        
        CIFaceFeature *faceFeature = [features objectAtIndex:0];
        CGPoint pos;
        //LOOK FOR LEFT EYE POS
        if ([feature isEqualToString:@"leftEye"]) {
            
            if (faceFeature.hasLeftEyePosition) {
                pos = faceFeature.leftEyePosition;
                NSLog(@"l Eye found");

            }else {NSLog(@"no left eye found");
                
            }
        
        //LOOK FOR RIGHT EYE POS
        }else if ([feature isEqualToString:@"rightEye"]) {
            
            if (faceFeature.hasRightEyePosition) {
                pos = faceFeature.rightEyePosition;
                NSLog(@"r Eye found");
                
            }else {NSLog(@"no right eye found");
                
            }
        
        //LOOK FOR MOUTH POS
        }else if ([feature isEqualToString:@"mouth"]) {
            
            if (faceFeature.hasMouthPosition) {
                pos = faceFeature.mouthPosition;
                NSLog(@"mouth found");
                
            }else {NSLog(@"no mouth found");
                
            }
        }else {
            NSLog(@"incorrect Key");
            return nil;
        }
        
        //convert core image point to UIKit point!!
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform,
                                               0, -img.size.height);
        pos = CGPointApplyAffineTransform(pos, transform);
        CGRect cgFaceBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        
        
        CGPoint center = CGPointMake(cgFaceBounds.size.width/2, cgFaceBounds.size.height/2);
        
        NSLog(@"pos: (%f, %f)\ncenter: (%f, %f)",pos.x, pos.y, center.x, center.y);
        
        NSNumber *dx = [NSNumber numberWithFloat:(pos.x - center.x)];
        NSNumber *dy = [NSNumber numberWithFloat:(pos.y - center.y)];
        
        NSArray *array = [[[NSArray alloc] initWithObjects:dx, dy, nil] autorelease];
        
        return array;
        
    }else {
        NSLog(@"no dydx face found");
        return nil;
    }
}
+ (NSArray *)getFacesFromImage:(UIImage *)image{
    
    //get context
    //CIContext *context = [CIContext contextWithEAGLContext:<#(EAGLContext *)#>]
    
    //face recognition
    CIImage *cgImg = [CIImage imageWithCGImage:image.CGImage];
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    //calibrated for portrait images, detect face
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray *features = [detector featuresInImage:cgImg options:imageOptions]; //fill array with detected
    
    //NSLog(@"\nimage size: %dx%d", (int)image.size.width, (int)image.size.height);
    NSMutableArray *faces = [[[NSMutableArray alloc] init] autorelease];
    if (features.count>0) {
        
        NSLog(@"Found %d face(s)",features.count);
        
        for (CIFaceFeature *faceFeature in features) {
            
            //find angle of face and correct
            CGPoint midPosBetweenEyes = ccpMidpoint(faceFeature.leftEyePosition, faceFeature.rightEyePosition);
            CGPoint mouthPos = faceFeature.mouthPosition;
            //legs of right triangle
            int dx = abs(mouthPos.x - midPosBetweenEyes.x);
            int dy = abs(mouthPos.y - midPosBetweenEyes.y);
            //angle of hypotenuse
            float faceAngle = degreesToRadians(atan2f(dx, dy));
            
            NSLog(@"face trigonometry \nmouthPos:(%.f,%.f) \nmidPosBetweenEyes:(%.f,%.f) \ndy:%d \ndx:%d \nDegrees: %f",mouthPos.x, mouthPos.y, midPosBetweenEyes.x, midPosBetweenEyes.y, dy, dx, faceAngle);
            //apply slight transform to straighten face
            //CGAffineTransform slightTrans = CGAffineTransformMakeRotation(faceAngle);
            //cgImg = [cgImg imageByApplyingTransform:slightTrans];
            
            //Crop out face, ROTATE face back, after adjusting for portrait
            CGAffineTransform angleNinety = CGAffineTransformMakeRotation(1.5*M_PI);
            CIImage *ciFace = [[cgImg imageByCroppingToRect:faceFeature.bounds] imageByApplyingTransform:angleNinety];
            //ciFace = [ciFace imageByApplyingTransform:slightTrans];
            UIImage *face = [UIImage imageWithCIImage:ciFace];
            UIImage *faceSized = [self imageWithImage:face scaledToSize:CGSizeMake(300, 300)];
            
            
            
            [faces addObject:faceSized];
        }
        
        NSLog(@"faces array: %d",[faces count]);
        
        return faces;
    }else {
        NSLog(@"No face detected");
        return nil;
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
        
    if (CC_CONTENT_SCALE_FACTOR() == 2.0) {//checks if in retina display mode
        // Retina display
        newSize = CGSizeMake(newSize.width*2, newSize.height*2); //half image size?
        UIGraphicsBeginImageContext( newSize );
        [image drawInRect:CGRectMake(0,0,newSize.width, newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    } else {
        // non-Retina display
        
        UIGraphicsBeginImageContext( newSize );
        [image drawInRect:CGRectMake(0,0,newSize.width, newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}
+ (UIImage *)scaleImageToWinSize:(UIImage *)image {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGSize scaledSize = winSize;
    float scaleFactor = 1;
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
        winSize = CGSizeMake(winSize.height*2, winSize.width*2/*winSize.width*2, winSize.height*2*/);
    }
    
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = winSize.width;
        scaledSize.height = winSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = winSize.height;
        scaledSize.width = winSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
    /*
    if (CC_CONTENT_SCALE_FACTOR() == 2.0) {//checks if in retina display mode
        // Retina display
        winSize = CGSizeMake(winSize.width*2, winSize.height*2); //half image size?
        UIGraphicsBeginImageContext( winSize );
        [image drawInRect:CGRectMake(0,0,winSize.width, winSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    } else {
        // non-Retina display
        
        UIGraphicsBeginImageContext( winSize );
        [image drawInRect:CGRectMake(0,0,winSize.width, winSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
     */
}
+ (UIImage *)scaleImageToWinsizeMaintainAspectRatio:(UIImage *)image{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
        winSize = CGSizeMake(winSize.height*2, winSize.width*2/*winSize.width*2, winSize.height*2*/);
    }
    
    float dx = abs(image.size.width - winSize.height);
    float dy = abs(image.size.height - winSize.width);
    float scale = winSize.height/image.size.width;
    CGSize rect;
    
    if (scale >=1) {
        if (dx<dy) {
            
            NSLog(@"scaleImageToWinsizeMaintainAspectRatio \ndx: %.f\ndy: %.f\nscale: %.2f", dx, dy, scale);
            rect = CGSizeMake(image.size.height*scale, image.size.width*scale);
        }else{
            scale = winSize.width/image.size.height;
            NSLog(@"scaleImageToWinsizeMaintainAspectRatio \ndx: %.f\ndy: %.f\nscale: %.2f", dx, dy, scale);
            rect = CGSizeMake(image.size.width*scale, image.size.height*scale);
        }
    }else{
        if (dx<dy) {
            //scale = winSize.height/image.size.width;
            NSLog(@"scaleImageToWinsizeMaintainAspectRatio \ndx: %.f\ndy: %.f\nscale: %.2f", dx, dy, scale);
            rect = CGSizeMake(image.size.height*scale, image.size.width*scale);
        }else{
            scale = winSize.width/image.size.height;
            NSLog(@"scaleImageToWinsizeMaintainAspectRatio \ndx: %.f\ndy: %.f\nscale: %.2f", dx, dy, scale);
            
            rect = CGSizeMake(image.size.width*scale, image.size.height*scale);
        }
    }
    
    
    UIGraphicsBeginImageContext(rect);
    [image drawInRect:CGRectMake(0,0,rect.width, rect.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;

}
+ (UIImage *)scaleImage:(UIImage *)image by:(float)scale{
    
    
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) { //checks if in retina mode
        // Retina display
        
        scale = scale*2; //double scale size?
        CGSize rect = CGSizeMake(image.size.width*scale, image.size.height*scale);
        UIGraphicsBeginImageContext(rect);
        [image drawInRect:CGRectMake(0,0,rect.width, rect.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    } else {
        // non-Retina display
        
        CGSize rect = CGSizeMake(image.size.width*scale, image.size.height*scale);
        UIGraphicsBeginImageContext(rect);
        [image drawInRect:CGRectMake(0,0,rect.width, rect.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }

    
    
}
+ (UIImage *)scaleImageRegardlessOfDisplayType:(UIImage *)image by:(float)scale{
    CGSize rect = CGSizeMake(image.size.width*scale, image.size.height*scale);
    UIGraphicsBeginImageContext(rect);
    [image drawInRect:CGRectMake(0,0,rect.width, rect.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+ (UIImage *)mergeImage:(UIImage *)first withImage:(UIImage*)second{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);

    //calculate the "centering" corner coordinates
    
    //NSLog(@"MergContext: %dx%d",(int)mergedSize.width, (int)mergedSize.height);
    //NSLog(@"second: %dx%d",(int)secondWidth, (int)secondHeight);
    
    [second drawInRect:CGRectMake((mergedSize.width-secondWidth)/2, (mergedSize.height-secondHeight)/2, secondWidth, secondHeight)]; 
    [first drawInRect:CGRectMake((mergedSize.width-firstWidth)/2, (mergedSize.height-firstHeight)/2, firstWidth, firstHeight)];
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage *)mergeAndArrangeImage:(UIImage *)first behindImage:(UIImage*)second atPoint:(CGPoint)pos{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //calculate the "centering" corner coordinates
    
    NSLog(@"MergContext: %dx%d",(int)mergedSize.width, (int)mergedSize.height);
    NSLog(@"second: %dx%d",(int)secondWidth, (int)secondHeight);
    
    //Draw images onto the context attempt to draw them centered in the contex

    [first drawInRect:CGRectMake((mergedSize.width-firstWidth)/2, (mergedSize.height-firstHeight)/2, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake((pos.x-secondWidth)/2, (pos.y-secondHeight)/2, secondWidth, secondHeight)]; 

    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)color1 endColor:(UIColor *)color2{
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height); //puts the origin in lower left of context?
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // Create gradient
    NSArray *colors = [NSArray arrayWithObjects:(id)color2.CGColor, (id)color1.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, NULL);
    
    // Apply gradient
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, img.size.height), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}
 
+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage; 
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, NO);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask); //INVERTED!!
    CGImageRelease(mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    //NSLog(@"mask finished");
	return maskedImage;
    
}
+ (UIImage *)maskImage:(UIImage *)image{
    
    image = [self imageWithImage:image scaledToSize:CGSizeMake(maskSize, maskSize)]; //retina issue
    CGImageRef maskRef = [UIImage imageNamed:@"bigMaskInv.png"].CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, NO);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask); //INVERTED!!
    CGImageRelease(mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    //NSLog(@"mask finished");
	return maskedImage;
    
}
+ (UIImage *)cropFace:(UIImage *)img{
    
    //size and mask the face
    //UIImage *imgSized = [self imageWithImage:img scaledToSize:CGSizeMake(30, 30)]; //retina issue
    UIImage *faceSizedAndMasked = [self maskImage:img withMask:[UIImage imageNamed:@"bigMaskInv.png"]];
    return faceSizedAndMasked;
}
+ (UIImage *)addDamageTo:(UIImage *)image atPosition:(CGPoint)p1 relativeToPos:(CGPoint)p2{
    
    CGImageRef imgRef = image.CGImage;
    CGFloat w = CGImageGetWidth(imgRef);
    CGFloat h = CGImageGetHeight(imgRef);
    /*
    UIImage *damage = [UIImage imageNamed:@"damage1.png"];
    CGFloat dw = damage.size.width;
    CGFloat dh = damage.size.height;
    */
    
    //CALCULATE where to add damage
    //NOT WORKING WELL YET...
    //Probably a problem with UIKit vs cocos coorinates
    
    NSLog(@"p1: (%d, %d)", (int)p1.x, (int)p1.y);
    NSLog(@"p2: (%d, %d)", (int)p2.x, (int)p2.y);
    
    float dy = (p1.y - p2.y);
    float dx = (p1.x - p2.x);
    float a = w/2+dx;
    float b = h/2-dy;
    
    NSLog(@"dx,dy: (%d, %d)", (int)dx, (int)dy);
    NSLog(@"a,b: (%d, %d)", (int)a, (int)b);
    

    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [image drawInRect:CGRectMake(0, 0, w, h)];
    
    
    //I don't understand why this works, but it does for making a transparanet circle section
    //source: http://stackoverflow.com/questions/1467392/how-to-paints-a-transparent-circle-like-using-cgcontextclearrect-to-draw-a-trans
    CGRect cirleRect = CGRectMake(a, b, 100, 100); 
    CGContextAddArc(context, 50+a, 50+b, 50, 0.0, 2*M_PI, 0);
    CGContextClip(context); 
    CGContextClearRect(context, cirleRect);

    //[damage drawInRect:CGRectMake((w-dw)/2, (h-dh)/2, dw, dh)];
    
    
    UIImage *damagedImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return damagedImg;
    
}
+ (UIImage *)drawCircleOnImage:(UIImage *)img atPosition:(CGPoint)point{
    
	UIImage *drawImage = [UIImage imageNamed:@"RightEyeMark.png"];		// input image to be composited over new image as example
    
	// create a new bitmap image context
	//
    CGSize size = CGSizeMake(img.size.width, img.size.height);
	UIGraphicsBeginImageContext(size);
    
	// get context
	//
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// push context to make it current
	// (need to do this manually because we are not drawing in a UIView)
	//
	UIGraphicsPushContext(context);
    
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
	// this example draws the inputImage into the context
	//
    
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //CIImage *ciImg = img.CIImage;
    
    //UIImage *imgFlipped = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:UIImageOrientationLeftMirrored];//[UIImage imageWithCIImage:[img.CIImage imageByApplyingTransform:CGAffineTransformMakeScale(1, -1)]];
    //[imgFlipped drawInRect:CGRectMake(0, 0, size.width, size.height)];
	[drawImage  drawInRect:CGRectMake(point.x, point.y, drawImage.size.width, drawImage.size.height)];
    
	// pop context
	//
	UIGraphicsPopContext();
    
	// get a UIImage from the image context- enjoy!!!
	//
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// clean up drawing environment
	//
	UIGraphicsEndImageContext();
    return outputImage;
}
+ (UIImage *)drawMouthPosOnImage:(UIImage *)img atPosition:(CGPoint)point{
    
	UIImage *drawImage = [UIImage imageNamed:@"mouthMark.png"];		// input image to be composited over new image as example
    
    CGSize size = CGSizeMake(img.size.width, img.size.height);
	
    UIGraphicsBeginImageContext(size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //UIImage *imgFlipped = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:UIImageOrientationLeftMirrored];
    //[imgFlipped drawInRect:CGRectMake(0, 0, size.width, size.height)];
	[drawImage  drawInRect:CGRectMake(point.x, point.y, drawImage.size.width, drawImage.size.height)];
	UIGraphicsPopContext();
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    return outputImage;
}
+ (UIImage *)drawLeftEyePosOnImage:(UIImage *)img atPosition:(CGPoint)point{
    
	UIImage *drawImage = [UIImage imageNamed:@"leftEyeMark.png"];		// input image to be composited over new image as example
    
    CGSize size = CGSizeMake(img.size.width, img.size.height);
	
    UIGraphicsBeginImageContext(size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //UIImage *imgFlipped = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:UIImageOrientationLeftMirrored];
    //[imgFlipped drawInRect:CGRectMake(0, 0, size.width, size.height)];
	[drawImage  drawInRect:CGRectMake(point.x, point.y, drawImage.size.width, drawImage.size.height)];
	UIGraphicsPopContext();
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    return outputImage;
}
+ (UIImage*) screenshotWithStartNode:(CCNode*)startNode{
    
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCRenderTexture* rtx =
    [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [rtx begin];
    [startNode visit];
    [rtx end];
    
    return [rtx getUIImageFromBuffer];
}
+ (ccColor3B)lightenSprite:(CCSprite *)sprite{    
    return ccc3(sprite.color.r+200, sprite.color.g+200, sprite.color.b+200);
}
@end
