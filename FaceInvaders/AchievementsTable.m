//
//  AchievementsTable.m
//  FaceInvaders
//
//  Created by Adam Erispaha on 12/11/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "AchievementsTable.h"

@implementation AchievementsTable
@synthesize table;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; //appdelegateIssue
        gameFont =  appDelegate.gameFont;//[[NSString alloc] initWithFormat:@"friendly robot"];
        
        //Set up table dimensions etc
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect tableRect = CGRectMake(0, 0, winSize.width/2, winSize.height);
        table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);
        [table setTransform:transform];
        
        //set delegates and data source
        [table setDelegate:self];
        [table setDataSource:self];
        
        //Set up table characteristics
        table.backgroundColor = [UIColor clearColor];
        table.opaque = NO;
        table.backgroundView = nil;
        table.center = CGPointMake(winSize.height/2, winSize.width/4); //UIkit coordinates
        table.allowsMultipleSelection = YES;
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        //get goals and achievments
        //goals = [[NSMutableArray alloc] initWithArray:[Achievments loadDataFromDisk]];
        goals = appDelegate.achievementsArray;
    
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
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [[CCDirector sharedDirector] drawScene];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [goals count];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.highlightedTextColor =  [UIColor yellowColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        
        
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        cell.textLabel.font = [UIFont fontWithName:appDelegate.gameFont size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:appDelegate.gameFont size:14];
        cell.imageView.transform = CGAffineTransformMakeScale(0.05, 0.05);
        
        //cell.imageView.frame.size = CGSizeMake(cell.frame.size.height*0.5, cell.frame.size.height*0.5);
    }
    Achievments *achievement = [goals objectAtIndex:indexPath.row];
    if (achievement.isAchieved) {
        cell.imageView.image = [UIImage imageNamed:@"greenStar.png"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.imageView.image = [UIImage imageNamed:@"yellowStar.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.imageView.alpha = 0.80;
    //date formatter
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MMM dd, yyyy  h:mm a"];
    [f setLocale:[NSLocale autoupdatingCurrentLocale]];
    NSString *date = [f stringFromDate:achievement.dateAchieved];
    [f release];
    
    cell.detailTextLabel.text = date;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    cell.textLabel.text = achievement.name;//[NSString stringWithFormat:@"%@", achievement.name];
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    
    cell.textLabel.font = [UIFont fontWithName:gameFont size:23];
    
    
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// I THINK THIS WILL CRASH DURING A FILTERED TABLE
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
    [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textColor = [UIColor yellowColor];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void)returnToIntroScene{
    NSLog(@"return to game over called");
    //[scoresTable removeFromSuperview];
    //[[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}
- (void)dealloc {
    [super dealloc];
    
}

@end
