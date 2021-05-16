//
//  PlayersViewController.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "PlayersViewController.h"

@interface PlayersViewController ()

@end

@implementation PlayersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor blueColor];
	// Do any additional setup after loading the view.
}
- (void)buttonSelected:(id)sender{
    NSLog(@"button clicked");
    [self dismissModalViewControllerAnimated:YES];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
