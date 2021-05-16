//
//  ShipScroller.h
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShipScroller : UIScrollView <UIScrollViewDelegate>{
    
}

@property (nonatomic, retain) UIScrollView  *scroller;
@property (nonatomic, retain) UIPageControl *pageControl;

@end
