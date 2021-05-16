//
//  CameraScene.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/20/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "CameraScene.h"
#import "TableOfPlayers.h"
#import "GameOverScene.h"
#import "IntroScene.h"

@implementation CameraScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [CameraLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation CameraLayer

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        
        
        [self openCamera];       
    }	
    return self;
}

- (void)openCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Camera is available");
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
        camera.hidesBottomBarWhenPushed = NO;
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;

        //Rotate that fucking camera. why needed? no fucking idea.
        //float   angle = 1.5*M_PI;
        //CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        //[camera.view setTransform:transform];
        camera.view.center = CGPointMake(winSize.height/2, winSize.width/2);
        
        [[[CCDirector sharedDirector] openGLView] addSubview:camera.view];
    }else {
        NSLog(@"did not access camera");
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType =  [info objectForKey:UIImagePickerControllerMediaType];   
    if ([mediaType isEqualToString:@"public.image"]){//not sure what this test is for...
        camImage = [info objectForKey:UIImagePickerControllerOriginalImage];//take picture
        
        //[self performSelectorInBackground:@selector(doHeavyStuffWithImage) withObject:nil];
        NSMutableArray *faces = [[NSMutableArray alloc] initWithArray:[ImageProcessor getFacesFromImage:camImage]];
        
        //File I/O
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDirectory = [paths objectAtIndex:0];
        
        
        //CHECK FIRST TO MAKE SURE A FILE IS NOT BEING OVERWRITTEN

        
        for (UIImage *face in faces) { //save all faces in captured image?
            
            NSArray *docFiles = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:docsDirectory error:NULL];
            NSString *fileName = [NSString stringWithFormat:@"face%d.png",[docFiles count]];
            
            NSLog(@"first attempt filename to be saved: %@",fileName);
            for (NSString *fname in docFiles) {
                if ([fileName isEqualToString:fname] ) {
                    int j, a = 0;
                    for (NSString *fname in docFiles) {
                        //grab the face number from file
                        int len = [fname length]-8; //length of file number
                        j = [[fname substringWithRange:NSMakeRange(4, len)] intValue];
                        //calculate the max number
                        a = MAX(a, j);
                        NSLog(@"j = %d\na = %d",j,a);
                    }
                    //fileName = [NSString stringWithFormat:@"face%d.png",a+1];
                    fileName = [NSString stringWithFormat:@"face%d.png",a+1];
                }   NSLog(@"selected filename: %@",fileName);
            }
            
            NSString *imagePath = [docsDirectory stringByAppendingPathComponent:fileName];
            //save as png. NOTE: PNGRep.. inverts the alpha layer, but this isn't an issue when merging with other images, so far
            
            [UIImagePNGRepresentation(face) writeToFile:imagePath atomically:YES];
            NSLog(@"saved face");
            NSArray *leftEye = [[NSArray alloc] init];
            
            leftEye = [ImageProcessor featureDxDyWithKey:@"leftEye" inImage:camImage];
            NSLog(@"\nleft Eye (%d):\n%@",[leftEye count], leftEye);
        }
        
        //CALCULATE LOCATIONS OF FEATURES HERE...
        //calculate center of face bounds
        //calculate dy, dx to mouth, left, right eyes, from center of face bounds
        //save dy, dx for mouth, R eye, and L eye - 6 arrays total (seems complicated...)
        [camera.view removeFromSuperview];
        [camera release];
        [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
    }
    
    
}

- (void)doHeavyStuffWithImage{
    //Get all faces in picture...
    if (camImage == nil) {
        NSLog(@"camImage is nill");
    }else {
        NSLog(@"camImage is not nill");
    }
    
   
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [camera.view removeFromSuperview];
    [camera release];
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{/* handle image saving information here...*/}

- (void)returnToGame{
    NSLog(@"return to game called");

    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}
- (void)viewPlayers{
    NSLog(@"View Players called");

    [[CCDirector sharedDirector] replaceScene:[TableOfPlayers scene]];
}
- (void)returnToMenu{
    NSLog(@"Return to Menu called");
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)dealloc {

    [super dealloc];
}


@end