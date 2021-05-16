//
//  HiScores.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 5/26/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "HiScores.h"
#import "IntroScene.h"

@implementation HiScores

@synthesize layer;
@synthesize scoresTable;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HiScores *layer = [HiScores node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect tableRect = CGRectMake(0, 0, winSize.width/2, winSize.height*2/3);
        
        scoresTable = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        
        [scoresTable setTransform:transform];
        [scoresTable setCenter:CGPointMake(winSize.height/2, winSize.width/2 - tableRect.size.width/2)];
        
        [[[[CCDirector sharedDirector] openGLView] window] addSubview:scoresTable];
        
        [scoresTable setDelegate:self];
        [scoresTable setDataSource:self];
        
        //Make the table transparent
        scoresTable.backgroundColor = [UIColor clearColor];
        scoresTable.opaque = NO;
        scoresTable.backgroundView = nil;
        //scoresTable.center = CGPointMake(winSize.width/4, winSize.height/2);
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray *currentHiScores = appDelegate.gamePlayerDataArray;
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"hiScore" ascending:NO] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        //NSArray *sortedHiScores = [[NSArray alloc] init];
        appDelegate.gamePlayerDataArray = [NSMutableArray arrayWithArray:[currentHiScores sortedArrayUsingDescriptors:sortDescriptors]];
        
        
    }
    return self;
}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //NSLog(@"scroll view will scroll");
    //[[CCDirector sharedDirector] drawScene];
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[CCDirector sharedDirector] drawScene];
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor purpleColor]];
    headerView.alpha = 0.7;
    
    //configure navigation button
    UIButton *backButt = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButt setFrame:CGRectMake(5, 5, 50, 30)];
    [backButt setTitle:@"Back" forState:UIControlStateNormal];
    [backButt setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    backButt.layer.borderWidth = 1;
    backButt.layer.cornerRadius = 0.8;
    backButt.layer.borderColor = [UIColor blackColor].CGColor;
    [backButt setBackgroundColor:[UIColor grayColor]];
    [backButt addTarget:self action:@selector(returnToIntroScene) forControlEvents:UIControlEventTouchUpInside];
    
    //Add title to Header
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, winSize.width/2, 30)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    titleLabel.text = [NSString stringWithFormat:@"Hi Scorz"];
    titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:25];
    titleLabel.center = CGPointMake(winSize.width/2, 20);
    [headerView addSubview:backButt];
    [headerView addSubview:titleLabel];
    
    
    return [headerView autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"Players"];
}
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate.gamePlayerDataArray count];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    GamePlayer *player = [appDelegate.gamePlayerDataArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    NSString *rankName;
    if (indexPath.row+1 < 10) {
        rankName = [NSString stringWithFormat:@" %d. %@",indexPath.row+1, player.name, player.hiScore];
    }else {
        rankName = [NSString stringWithFormat:@"%d. %@",indexPath.row+1, player.name, player.hiScore];
    }
    
    NSString *scoreTxt = [NSString stringWithFormat:@"%ld", player.hiScore];
    cell.textLabel.text = rankName;
    cell.detailTextLabel.text = scoreTxt;
    cell.textLabel.textColor = [UIColor yellowColor];
    
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Code used for deleting players in the TableOfPlayers
    /*
    NSLog(@"trying to delete index row %d",indexPath.row);
    //File I/O
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirectory = [paths objectAtIndex:0];
    NSError *err;
    NSString *imagePath = [docsDirectory stringByAppendingPathComponent:[docFiles objectAtIndex:indexPath.row]];
    
    NSLog(@"DocFile %d: %@",indexPath.row,[docFiles objectAtIndex:indexPath.row]);
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([docFiles count] >= 2) {//prevent whole table from being deleted
            // Delete the row from the data source
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            NSLog(@"Deleting: %@",[docFiles objectAtIndex:indexPath.row]);
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&err];
            [docFiles removeObjectAtIndex:indexPath.row];
            [tableView endUpdates];
        }
        
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    */
}
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
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
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)dealloc {
    [layer release];
    layer = nil;
    [scoresTable release];
    [super dealloc];
    
}

@end
