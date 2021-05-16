//
//  TableOfPlayers.m
//  Cocos2DSimpleGame
//
//  Created by Adam Erispaha on 4/30/12.
//  Copyright (c) 2012 EychmoTech. All rights reserved.
//

#import "TableOfPlayers.h"

@implementation TableOfPlayers
@synthesize layer;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TableOfPlayers *layer = [TableOfPlayers node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init {
    
    if ((self = [super init])) {
   
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect tableRect = CGRectMake(0, 0, winSize.width, winSize.height);
        
        playerTable = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0.5*M_PI);

        [playerTable setTransform:transform];
        [playerTable setCenter:CGPointMake(winSize.height/2, winSize.width/2)];
                                      
        [[[[CCDirector sharedDirector] openGLView] window] addSubview:playerTable];
        
        [playerTable setDelegate:self];
        [playerTable setDataSource:self];
        
        //Make the table transparent
        playerTable.backgroundColor = [UIColor clearColor];
        playerTable.opaque = NO;
        playerTable.backgroundView = nil;
        
        }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    headerView.alpha = 0.7;
    
    //configure navigation button
    UIButton *backButt = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButt setFrame:CGRectMake(5, 5, 50, 30)];
    [backButt setTitle:@"Menu" forState:UIControlStateNormal];
    [backButt setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    backButt.layer.borderWidth = 1;
    backButt.layer.cornerRadius = 0.8;
    backButt.layer.borderColor = [UIColor blackColor].CGColor;
    [backButt setBackgroundColor:[UIColor grayColor]];
    [backButt addTarget:self action:@selector(returnToGameOver) forControlEvents:UIControlEventTouchUpInside];
    
    //Add title to Header
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.text = [NSString stringWithFormat:@"Available Players"];
    titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:25];
    [titleLabel setTextColor:[UIColor yellowColor]];
    titleLabel.center = CGPointMake(winSize.width/2, 20);
    [headerView addSubview:backButt];
    [headerView addSubview:titleLabel];
    
    [titleLabel release];
    
    return [headerView autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"Players"];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirectory = [paths objectAtIndex:0];
    docFiles = [[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:docsDirectory error:NULL]];
    
    return [docFiles count];

}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [docFiles objectAtIndex:indexPath.row];
    NSString *imagePath = [docsDirectory stringByAppendingPathComponent:fileName];
    
    NSMutableArray *arr = [[[NSMutableArray alloc] initWithObjects:imagePath, indexPath, nil] autorelease];
    
    [self performSelectorInBackground:@selector(loadImageAtIndexPath:) withObject:arr];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(18,50+(100*indexPath.row), 80, 80)] autorelease];
    imageView.layer.frame.cornerRadius = 8;
    imageView.tag = indexPath.row+1;
    [playerTable addSubview:imageView];
    /*
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 80, 80)];
    imageView.tag = indexPath.row+1;
    [[playerTable cellForRowAtIndexPath:indexPath] addSubview:imageView];
    */
    // Configure the cell...
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    
    cell.textLabel.text = fileName;
    cell.textLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:25];
    
    //add switches to each cell (to turn off players in future)
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [switchView release];
    
    //[[cell imageView] setImage:img]; 
    
    NSLog(@"filename %@",fileName);

    return cell;
}
-(void)switchChanged:(id)sender{
    
}
- (void)loadImageAtIndexPath:(NSArray *)arr{
    
    NSData *data = [NSData dataWithContentsOfFile:[arr objectAtIndex:0]];
    UIImage *img = [UIImage imageWithData:data];//[[UIImage alloc] initWithData:data];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:img, [arr objectAtIndex:1], nil];
    
    //NSLog(@"loading %d: %@",indexPath.row,[docFiles objectAtIndex:indexPath.row]);
    NSLog(@"docFiles:%d",[docFiles count]);
    //[self performSelectorOnMainThread:@selector(assignImgToCell:) withObject:array waitUntilDone:YES];
    [self performSelectorInBackground:@selector(assignImgToCell:) withObject:array];
}
- (void)assignImgToCell:(NSMutableArray *)arr{
    NSLog(@"subviews:%d",[[playerTable subviews] count]);
    for (UIImageView *checkView in [playerTable subviews]) {

        NSIndexPath *index = [arr objectAtIndex:1];
        NSLog(@"CurrIndex:%d",index.row+1);
        NSLog(@"checkViewDims:%dx%d",(int)checkView.frame.size.width,(int)checkView.frame.size.width );
        
        if (checkView.tag == index.row+1) {
            UIImage *img = [arr objectAtIndex:0];
            
            [checkView setImage:img];
            
        }
    }

}
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
     return YES;
 }
 

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
 }
 



 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
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
 return 100.0f;
 }


- (void)returnToGameOver{
    NSLog(@"return to game over called");
    [playerTable removeFromSuperview];

    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"Lose."];
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}

- (void)dealloc {
    [layer release];
    layer = nil;
    [playerTable release];
    [super dealloc];
    
}

@end
