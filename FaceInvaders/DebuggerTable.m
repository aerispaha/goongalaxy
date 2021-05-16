//
//  DebuggerTable.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 10/29/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "DebuggerTable.h"

@implementation DebuggerTable
@synthesize table;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        tableScale = 0.667; //0.5 would fill half of screen
        //grab Facebook session and screen shot images
        fb = [[Facebook alloc] init];
        fb = appDelegate.facebook;
        debugImgArray = [[NSMutableArray alloc] init];
        //do this now for faster table
        for (UIImage *screenImg in appDelegate.debuggerImages) {
            if (CC_CONTENT_SCALE_FACTOR() == 2) {
                screenImg = [ImageProcessor  scaleImageRegardlessOfDisplayType:screenImg by:tableScale*0.5];
            }else{
                screenImg = [ImageProcessor scaleImage:screenImg by:tableScale];
            }
            [debugImgArray addObject:screenImg];
        }
        //create table
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        CGRect tableRect = CGRectMake(0, 0, winSize.width*tableScale, winSize.height);
        table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        [table setTransform:transform];
        [table setDelegate:self];
        [table setDataSource:self];
        
        //Configure the table
        table.backgroundColor = [UIColor clearColor];
        table.opaque = NO;
        table.backgroundView = nil;
        table.center = CGPointMake(winSize.height/2, winSize.width*(tableScale/2)); //UIkit coordinates
        table.allowsMultipleSelection = NO;
        [table setSeparatorStyle:UITableViewCellSelectionStyleGray];
        
        //others

    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [debugImgArray count];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    // Configure the cell...
    UIView  *backView           = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    UIImage *screenImg          = [debugImgArray objectAtIndex:indexPath.row];
    UIColor *screenImgUIColor   = [[[UIColor alloc] initWithPatternImage:screenImg] autorelease];
    backView.backgroundColor    = screenImgUIColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = backView;
    //cell.textLabel.textColor = [UIColor yellowColor];
    
    
    NSLog(@"cell returned");
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    picIndexPath = indexPath.row;
    
    
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[CCDirector sharedDirector]winSize].width;//*tableScale;
}

@end
