//
//  ShipScroller.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "ShipScroller.h"

@implementation ShipScroller
@synthesize scroller;
@synthesize pageControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        scroller = [[UIScrollView alloc]initWithFrame:frame];
        
        NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
        for (int i = 0; i < colors.count; i++) {
            CGRect frame;
            frame.origin.x = scroller.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = scroller.frame.size;
            
            UIView *subview = [[UIView alloc] initWithFrame:frame];
            subview.backgroundColor = [colors objectAtIndex:i];
            [scroller addSubview:subview];
            [subview release];
        }
        
        scroller.contentSize = CGSizeMake(scroller.frame.size.width * colors.count, scroller.frame.size.height);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        [scroller setTransform:transform];
        
        scroller.pagingEnabled = YES;
    }
    return self;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scroller.frame.size.width;
    int page = floor((scroller.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

@end
