//
//  HiScoreTable.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 7/12/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "HiScoreTable.h"
#import "cocos2d.h"

@implementation HiScoreTable
@synthesize scoresTable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
        gameFont = appDelegate.gameFont;//[[NSString alloc] initWithFormat:@"friendly robot"];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect tableRect = CGRectMake(0, 0, winSize.width/2, winSize.height*2/3);
        
        scoresTable = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        [scoresTable setTransform:transform];
        
        [scoresTable setDelegate:self];
        [scoresTable setDataSource:self];
        
        //Make the table transparent
        scoresTable.backgroundColor = [UIColor clearColor];
        scoresTable.opaque = NO;
        scoresTable.backgroundView = nil;
        scoresTable.center = CGPointMake(winSize.height/2, winSize.width/4);
        
        
        NSMutableArray *currentHiScores = appDelegate.gamePlayerDataArray;
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"hiScore" ascending:NO] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        //NSArray *sortedHiScores = [[NSArray alloc] init];
        appDelegate.gamePlayerDataArray = [NSMutableArray arrayWithArray:[currentHiScores sortedArrayUsingDescriptors:sortDescriptors]]; //crashed here on fist start up
        scoresTable.allowsSelection = NO;
        
        self.scoresTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.viewForBaselineLayout.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    return [appDelegate.gamePlayerDataArray count];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
    GamePlayer *player = [appDelegate.gamePlayerDataArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    NSString *rankName;
    if (indexPath.row+1 < 10) {
        rankName = [NSString stringWithFormat:@"  %d. %@",indexPath.row+1, player.name];
    }else {
        rankName = [NSString stringWithFormat:@"%d. %@",indexPath.row+1, player.name];
    }
    
    NSString *scoreTxt = [NSString stringWithFormat:@"%ld", player.hiScore];
    cell.textLabel.text = rankName;
    cell.textLabel.font = [UIFont fontWithName:gameFont size:17];
    cell.detailTextLabel.text = scoreTxt;
    cell.detailTextLabel.font = [UIFont fontWithName:gameFont size:10];
    cell.textLabel.textColor = [UIColor yellowColor];
    
    
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return YES;// Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationMaskLandscapeLeft);
}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (void)returnToIntroScene{
    NSLog(@"return to game over called");
    [scoresTable removeFromSuperview];
    //[[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)dealloc {

    [scoresTable release];
    [gameFont release];
    [super dealloc];
    
}

@end

