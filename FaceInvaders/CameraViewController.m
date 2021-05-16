//
//  CameraViewController.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 8/27/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"CameraViewController initWithNibName called");
        timesAppeared = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"CameraViewController viewDidLoad called");
}

- (void)viewDidAppear:(BOOL)animated{
    timesAppeared++;
    if (timesAppeared == 3) {
        NSLog(@"CameraViewController viewDidAppear called");
        timesAppeared = 0;

        //[self release];
        //self = nil;
    }

    NSLog(@"CameraViewController viewDidAppear called 2");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
